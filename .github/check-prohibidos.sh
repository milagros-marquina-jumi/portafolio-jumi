#!/usr/bin/env bash
# Bloqueo de archivos prohibidos: secretos, artefactos, codigo de terceros,
# ejecutables y restos del incidente 2026-09-01.
#
# Una sola definicion, tres puntos de aplicacion, para que el hook local y el
# CI no puedan divergir:
#   bash scripts/check-prohibidos.sh --indice          (hook pre-commit)
#   bash scripts/check-prohibidos.sh --arbol           (CI: todo lo versionado)
#   bash scripts/check-prohibidos.sh --rango A..B      (CI: lo que trae el push/PR)
#
# Parametrizado por perfil a traves del entorno. Sin variables definidas se
# comporta EXACTAMENTE igual que la copia original del Vault.
#   MTS_LISTA_EJECUTABLES  allowlist de ejecutables (def. .github/ejecutables-permitidos.txt)
#   MTS_RUTA_DETECTOR      ruta canonica del detector (def. .github/scan-malware.sh).
#                          Cualquier otro archivo con ese nombre se bloquea:
#                          el detector se excluye del barrido de firmas POR
#                          NOMBRE, asi que una copia en otra carpeta seria una
#                          zona ciega.
#   MTS_BLOQUEAR_SCRIPTS   1 = un .sh/.py/.js fuera de la allowlist se bloquea.
#                          0 = solo se aplica el bit 100755. Un repositorio de
#                          codigo no puede prohibir fuentes; ver la limitacion
#                          aceptada en el ADR-0011.
#
# Salida 0 solo si no hay prohibidos Y se pudo consultar a git.
# Compatible con bash 3.2 (macOS), Git Bash (Windows) y Ubuntu (CI).

set -uo pipefail
export LC_ALL=C

modo="${1:-}"
rango="${2:-}"

tmp=$(mktemp -d 2>/dev/null) || { echo "ERROR: mktemp fallo. No se puede verificar."; exit 1; }
trap 'rm -rf "$tmp"' EXIT

# rc se captura dentro de cada rama y se comprueba explicitamente: nada de
# `< <(git ...)`, donde el estado de salida se pierde y un git que falla se
# leeria como "no hay archivos que revisar".
rc=0
case "$modo" in
  --indice)
    git diff --cached --name-only --diff-filter=ACMR -z > "$tmp/lst" 2>"$tmp/err" || rc=$? ;;
  --arbol)
    git ls-files -z > "$tmp/lst" 2>"$tmp/err" || rc=$? ;;
  --rango)
    # Recorrido COMMIT A COMMIT, no diferencia entre extremos. Con
    # `git diff base..head` un archivo agregado en un commit y borrado en otro
    # posterior no aparece, y ese es justo el caso de un secreto que se
    # commitea y se "arregla" despues: sigue en el historial publicado.
    # Ademas, comparar extremos hacia el arbol final lo hace redundante con
    # --arbol, que ya cubre todo lo versionado.
    [ -n "$rango" ] || { echo "ERROR: --rango necesita <base>..<head>."; exit 1; }
    git log -z --format= --name-only --diff-filter=ACMR "$rango" \
      > "$tmp/lst" 2>"$tmp/err" || rc=$? ;;
  *)
    echo "Uso: $0 --indice | --arbol | --rango <base>..<head>"; exit 1 ;;
esac
if [ "$rc" -ne 0 ]; then
  echo "ERROR: git fallo listando archivos ($modo). No se puede verificar."
  sed 's/^/    /' "$tmp/err"
  exit 1
fi

# Allowlist de ejecutables propios del repositorio.
# El repositorio versiona notas MAS los controles de seguridad, que son
# scripts. Para que "nada ejecutable entra al historial" no sea una frase
# falsa, los pocos ejecutables autorizados se declaran uno a uno en
# .github/ejecutables-permitidos.txt y cualquier otro se bloquea.
# Si ese archivo no existe, esta comprobacion no se aplica (repos de codigo).
permitidos_lista="${MTS_LISTA_EJECUTABLES:-.github/ejecutables-permitidos.txt}"
case "$permitidos_lista" in
  /*|*..*) echo "ERROR: MTS_LISTA_EJECUTABLES debe ser relativa y sin '..': '$permitidos_lista'."; exit 1 ;;
esac
ruta_detector="${MTS_RUTA_DETECTOR:-.github/scan-malware.sh}"
ruta_detector=$(printf '%s' "$ruta_detector" | tr 'A-Z' 'a-z')
bloquear_scripts="${MTS_BLOQUEAR_SCRIPTS:-1}"
case "$bloquear_scripts" in
  0|1) ;;
  *) echo "ERROR: MTS_BLOQUEAR_SCRIPTS debe ser 0 o 1: '$bloquear_scripts'."; exit 1 ;;
esac
hay_allowlist=0
[ -f "$permitidos_lista" ] && hay_allowlist=1

ejecutable_permitido() {
  local ruta="$1" patron
  while IFS= read -r patron || [ -n "$patron" ]; do
    patron=$(printf '%s' "$patron" | tr -d '\r')
    case "$patron" in ""|\#*) continue ;; esac
    # $patron va SIN comillas a proposito: es un glob y tiene que expandirse,
    # porque la allowlist admite entradas como 'scripts/*.sh'. Entrecomillarlo
    # (que es lo que pide SC2254) lo volveria una comparacion literal y ninguna
    # entrada con comodin volveria a coincidir: todos los ejecutables
    # declarados pasarian a bloquearse.
    # A diferencia de .scanignore, esta lista NO se valida por forma: vive en
    # el repositorio evaluado y un patron demasiado amplio ('*') autorizaria
    # cualquier ejecutable. Lo que lo contiene es que el archivo esta en
    # CODEOWNERS y, en pull_request, se lee desde la rama base.
    # shellcheck disable=SC2254
    case "$ruta" in $patron) return 0 ;; esac
  done < "$permitidos_lista"
  return 1
}

: > "$tmp/bloqueados"
while IFS= read -r -d '' ruta; do
  baja=$(printf '%s' "$ruta" | tr 'A-Z' 'a-z')
  base="${baja##*/}"
  motivo=""

  # Secretos
  case "$base" in
    .env.example) ;;
    .env|.env.*|.npmrc|.netrc|id_rsa|id_rsa.*|id_ed25519|id_ed25519.*) motivo="secreto" ;;
    credentials*.json|*.pem|*.key|*.p12|*.pfx|*.ppk|*.jks|*.keystore) motivo="secreto" ;;
  esac
  case "$baja" in
    *serviceaccountkey*|*secrets.env*) motivo="secreto" ;;
  esac

  # Historial exportado
  # Un bundle contiene el historial completo, incluidos los commits con el
  # payload del incidente. Republicarlo anularia el reinicio de historial.
  case "$base" in
    *.bundle|*.pack|*.idx) [ -z "$motivo" ] && motivo="historial exportado" ;;
  esac

  # Dependencias, configuracion local y codigo de terceros
  case "/$baja" in
    */node_modules/*|*/.vscode/*|*/.claude/*|*/.idea/*) [ -z "$motivo" ] && motivo="config local o dependencia" ;;
    */.obsidian/plugins/*|*/.obsidian/themes/*|*/.obsidian/snippets/*) [ -z "$motivo" ] && motivo="codigo de terceros" ;;
    */dist/*|*/build/*|*/.next/*|*/coverage/*|*/.turbo/*) [ -z "$motivo" ] && motivo="artefacto de build" ;;
  esac

  # Kit del incidente 2026-09-01
  case "$baja" in
    *temp_auto_push*|*temp_interactive_push*|branch_structure.json) [ -z "$motivo" ] && motivo="kit del incidente" ;;
  esac

  # Binarios y ejecutables
  case "$base" in
    *.exe|*.dll|*.so|*.dylib|*.msi|*.bat|*.cmd|*.ps1|*.psm1|*.vbs|*.scr) [ -z "$motivo" ] && motivo="ejecutable" ;;
    *.jar|*.apk|*.wasm|*.pyc|*.lnk) [ -z "$motivo" ] && motivo="binario" ;;
  esac

  # Suplantacion del detector
  # El detector se excluye a si mismo del barrido de firmas POR NOMBRE, asi
  # que un scan-malware.sh en otra carpeta seria una zona ciega.
  # La ruta canonica es un dato del proyecto: en un repositorio que consume el
  # motor es .github/, y en el propio motor es scripts/.
  if [ "$base" = "scan-malware.sh" ] && [ "$baja" != "$ruta_detector" ]; then
    motivo="suplantacion del detector"
  fi

  # Scripts fuera de la allowlist
  if [ -z "$motivo" ] && [ "$hay_allowlist" -eq 1 ] && [ "$bloquear_scripts" -eq 1 ]; then
    case "$base" in
      *.sh|*.py|*.js|*.mjs|*.cjs|*.rb|*.pl)
        ejecutable_permitido "$ruta" || motivo="script no declarado en $permitidos_lista" ;;
    esac
  fi

  [ -n "$motivo" ] && printf '%s :: %s\0' "$ruta" "$motivo" >> "$tmp/bloqueados"
done < "$tmp/lst"

# Bit ejecutable fuera de la allowlist
# Un script sin extension (o con una inocente) igual se ejecuta si lleva el bit
# 100755. En Windows con core.fileMode=false esto no detecta nada; por eso el
# CI, que corre en Linux, es el que manda aqui.
if [ "$hay_allowlist" -eq 1 ] && [ "$modo" != "--rango" ]; then
  if git ls-files -s -z > "$tmp/modos" 2>/dev/null; then
    while IFS= read -r -d '' linea; do
      case "$linea" in 100755\ *) ;; *) continue ;; esac
      ruta="${linea#*	}"
      ejecutable_permitido "$ruta" || \
        printf '%s :: bit ejecutable no declarado en %s\0' "$ruta" "$permitidos_lista" >> "$tmp/bloqueados"
    done < "$tmp/modos"
  fi
fi

if [ -s "$tmp/bloqueados" ]; then
  echo "PROHIBIDOS: hay archivos que no pueden entrar al historial ($modo):"
  while IFS= read -r -d '' entrada; do
    printf '    %s\n' "$entrada"
  done < "$tmp/bloqueados"
  exit 1
fi

echo "OK: ningun archivo prohibido ($modo)."
exit 0
