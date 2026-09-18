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
#   MTS_BLOQUEAR_SCRIPTS   1 = un .sh/.py/.js/.ps1 fuera de la allowlist se
#                          bloquea.
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

# Un .npmrc no es un secreto por existir. El mapeo de un ambito a un registro
# -"@mimotech:registry=https://npm.pkg.github.com"- es configuracion publica, y
# cualquier consumidor de un paquete privado la necesita versionada para poder
# resolverlo. Lo que no puede entrar es una credencial.
#
# Asi que aqui se mira el contenido y no el nombre. Se bloquea si una directiva
# de credencial trae un valor literal; se deja pasar si esta vacia o si es una
# interpolacion de entorno -"${GITHUB_TOKEN}"-, que es como se escribe cuando el
# token lo inyecta el CI y no el archivo.
#
# Si el contenido no se puede leer, se bloquea. Ante la duda el fallo es cerrado:
# preferimos rechazar un archivo legitimo a publicar un token.
# Lee el contenido del fichero en TODAS las versiones que toca el modo y lo
# deja en $tmp/contenido: la del indice, la del arbol, o una por commit del
# rango -un token commiteado y borrado despues sigue en el historial que se
# empuja-. Devuelve 1 si no se pudo leer ninguna: el que llama decide, y en
# este script decide bloquear.
versiones_de() { # versiones_de <ruta>
  local ruta="$1"
  local leido=0
  : > "$tmp/contenido"

  case "$modo" in
    --indice)
      git show ":$ruta" >> "$tmp/contenido" 2>/dev/null && leido=1 ;;
    --arbol)
      if [ -f "$ruta" ]; then
        cat -- "$ruta" >> "$tmp/contenido" 2>/dev/null && leido=1
      else
        git show ":$ruta" >> "$tmp/contenido" 2>/dev/null && leido=1
      fi ;;
    --rango)
      local commit
      while IFS= read -r commit; do
        [ -n "$commit" ] || continue
        if git show "$commit:$ruta" >> "$tmp/contenido" 2>/dev/null; then
          leido=1
          printf '\n' >> "$tmp/contenido"
        fi
      done <<EOF_COMMITS
$(git rev-list "$rango" 2>/dev/null)
EOF_COMMITS
      ;;
  esac

  [ "$leido" -eq 1 ]
}

npmrc_con_credencial() { # npmrc_con_credencial <ruta>
  local ruta="$1"

  # Sin contenido legible no hay veredicto, y sin veredicto se bloquea.
  versiones_de "$ruta" || return 1

  while IFS= read -r linea; do
    case "$linea" in
      \#*|"") continue ;;
    esac
    case "$linea" in
      *_authToken=*|*_auth=*|*_password=*)
        valor="${linea#*=}"
        valor="${valor%%[[:space:]]*}"
        case "$valor" in
          "") ;;
          '${'*'}') ;;
          *) exit 1 ;;
        esac ;;
    esac
  done < "$tmp/contenido"
  return 0
}

# Credenciales por CONTENIDO, no por nombre de fichero.
#
# Hasta la 0.12.0 este script solo miraba nombres. Un token real dentro de un
# fichero de nombre inocente pasaba limpio, y paso: bizner-projects-back llevo
# un PAT de GitHub -ghp_...- dentro de .env.example, que es un nombre PERMITIDO,
# hasta el commit inicial de su repositorio migrado. migrar-repo.sh anuncio
# "sin secretos ni artefactos" con el token dentro.
#
# Se buscan formatos de token con prefijo fijo y longitud conocida: la
# probabilidad de que un texto legitimo los produzca por azar es despreciable,
# asi que no hay allowlist. Lo unico que se perdona son los placeholders
# evidentes -ocho X seguidas, ocho ceros, asteriscos, puntos suspensivos-,
# porque un .env.example los necesita. Un token real no tiene excepcion.
#
# Un fichero binario no se mira: un PNG puede contener AKIA seguido de dieciseis
# mayusculas por puro azar. Y uno que no se pueda leer se bloquea.
# Tabla: patron<TAB>tipo. Se lee una vez; la alternancia de todos sirve para
# un unico grep por fichero -y en --arbol, uno por lote de ficheros-. Con un
# grep por patron el arbol de bizner-projects-back no terminaba en diez minutos
# en Windows, donde cada proceso cuesta.
PATRONES_CREDENCIAL='ghp_[A-Za-z0-9]{36}	token de GitHub
gh[ousr]_[A-Za-z0-9]{36}	token de GitHub
github_pat_[A-Za-z0-9_]{22,}	token de GitHub
AKIA[0-9A-Z]{16}	clave de acceso de AWS
GOCSPX-[A-Za-z0-9_-]{20,}	secreto OAuth de Google
AIza[0-9A-Za-z_-]{35}	clave de API de Google
re_[A-Za-z0-9]{8}_[A-Za-z0-9]{16,}	clave de Resend
[sr]k_live_[A-Za-z0-9]{20,}	clave de Stripe
sk-ant-[A-Za-z0-9_-]{30,}	clave de Anthropic
sk-proj-[A-Za-z0-9_-]{30,}	clave de OpenAI
xox[baprs]-[A-Za-z0-9-]{10,}	token de Slack
npm_[A-Za-z0-9]{36}	token de npm
glpat-[A-Za-z0-9_-]{20}	token de GitLab
hf_[A-Za-z0-9]{30,}	token de Hugging Face
f[om][12]_[A-Za-z0-9_-]{40,}	token de Fly
SG\.[A-Za-z0-9_-]{22}\.[A-Za-z0-9_-]{43}	clave de SendGrid
-----BEGIN [A-Z ]*PRIVATE KEY-----	clave privada'
PATRON_CREDENCIAL_TODOS=$(printf '%s\n' "$PATRONES_CREDENCIAL" | cut -f1 | paste -sd'|' -)
PLACEHOLDERS='X{8}|x{8}|0{8}|\*{4}|\.\.\.'

# Que tipo de credencial hay en $tmp/contenido. Devuelve 0 e imprime el tipo.
tipo_de_credencial() {
  local patron tipo
  while IFS='	' read -r patron tipo; do
    [ -n "$patron" ] || continue
    if LC_ALL=C grep -oE -e "$patron" "$tmp/contenido" 2>/dev/null | LC_ALL=C grep -qvE "$PLACEHOLDERS"; then
      echo "$tipo"
      return 0
    fi
  done <<EOF_PATRONES
$PATRONES_CREDENCIAL
EOF_PATRONES
  return 1
}

credencial_en_contenido() { # credencial_en_contenido <ruta>  -> imprime el tipo y devuelve 0 si hay
  local ruta="$1"
  versiones_de "$ruta" || { echo "contenido ilegible"; return 0; }

  # Un solo grep con todos los patrones descarta el 99% de los ficheros con
  # un proceso. Solo si algo casa se mira el binario y el tipo.
  LC_ALL=C grep -qE -e "$PATRON_CREDENCIAL_TODOS" "$tmp/contenido" 2>/dev/null || return 1

  # Binario = contiene bytes NUL. No vale "algun byte no imprimible": en locale
  # C una enie o una tilde en un comentario ya lo es, y un .env.example con
  # comentarios en espanol se saltaba entero. wc -c y no [ -n ], porque bash
  # descarta los NUL al capturar la salida y la variable quedaria vacia.
  if [ "$(LC_ALL=C tr -dc '\000' < "$tmp/contenido" | wc -c)" -gt 0 ]; then
    return 1
  fi

  tipo_de_credencial
}

# En --arbol los ficheros estan en disco: un grep por lote de doscientos deja
# la lista de candidatos, y el bucle principal solo lee los que aparecen ahi.
: > "$tmp/candidatos"
if [ "$modo" = "--arbol" ]; then
  # xargs -0 y no -d: -d es solo GNU y esto tiene que correr en macOS. El
  # guard de $# evita que un grep sin ficheros se quede leyendo la entrada.
  xargs -0 -n 200 sh -c '[ $# -gt 0 ] || exit 0; LC_ALL=C grep -lE -e "$0" -- "$@" 2>/dev/null; :' \
    "$PATRON_CREDENCIAL_TODOS" < "$tmp/lst" > "$tmp/candidatos" || true
fi
es_candidato() { # es_candidato <ruta>: en --arbol, solo los que el barrido marco
  [ "$modo" != "--arbol" ] && return 0
  grep -qxF -- "$1" "$tmp/candidatos"
}

: > "$tmp/bloqueados"
while IFS= read -r -d '' ruta; do
  baja=$(printf '%s' "$ruta" | tr 'A-Z' 'a-z')
  base="${baja##*/}"
  motivo=""

  # Secretos
  #
  # El patron cubre CUALQUIER fichero que termine en .env, no solo los que
  # empiezan por punto. `development.env` y `config/prod.env` son ficheros de
  # entorno igual que `.env`, y hasta la 0.11.0 pasaban limpios: lo destapo
  # bizner-projects-back, cuyo config/enviroments/development.env alojo un AKIA
  # de AWS, un GOCSPX- de Google, un ghp_ de GitHub y un re_ de Resend. El
  # control decia "ningun archivo prohibido" con los cuatro dentro.
  case "$base" in
    .env.example|*.env.example) ;;
    .env|.env.*|*.env|.netrc|id_rsa|id_rsa.*|id_ed25519|id_ed25519.*) motivo="secreto" ;;
    .npmrc) npmrc_con_credencial "$ruta" || motivo="secreto (credencial en .npmrc)" ;;
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
  #
  # .ps1 y .psm1 NO estan aqui: son fuentes de texto plano, como .sh o .py, y
  # Windows no los ejecuta al abrirlos -el Explorador los manda al Bloc de notas
  # y la directiva de ejecucion los bloquea-. Se tratan como scripts, abajo.
  # .bat, .cmd, .vbs y .scr si arrancan con un doble clic, y siguen bloqueados.
  case "$base" in
    *.exe|*.dll|*.so|*.dylib|*.msi|*.bat|*.cmd|*.vbs|*.scr) [ -z "$motivo" ] && motivo="ejecutable" ;;
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

  # Credenciales en el contenido, sea cual sea el nombre
  if [ -z "$motivo" ]; then
    if es_candidato "$ruta"; then
      tipo=$(credencial_en_contenido "$ruta") && motivo="secreto en el contenido ($tipo)"
    fi
  fi

  # Scripts fuera de la allowlist
  if [ -z "$motivo" ] && [ "$hay_allowlist" -eq 1 ] && [ "$bloquear_scripts" -eq 1 ]; then
    case "$base" in
      *.sh|*.py|*.js|*.mjs|*.cjs|*.rb|*.pl|*.ps1|*.psm1)
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
