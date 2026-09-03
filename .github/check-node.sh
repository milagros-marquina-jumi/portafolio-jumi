#!/usr/bin/env bash
# Higiene de dependencias en un repositorio de Node.
#
#   bash scripts/check-node.sh --lockfile
#   bash scripts/check-node.sh --scripts
#   bash scripts/check-node.sh --todo
#
# Cubre el vector concreto del incidente 2026-09-01: codigo de terceros que se
# ejecuta al instalar, sin que nadie lo lea. No sustituye a `npm audit` ni a un
# job de build; son preguntas distintas.
#
# Lee del entorno:
#   MTS_LISTA_SCRIPTS_INSTALACION  allowlist de scripts de instalacion
#                                  (def. .github/scripts-instalacion-permitidos.txt)
#
# Falla cerrado: si no puede leer un package.json que existe, aborta.

set -uo pipefail
export LC_ALL=C

fail=0
gestores=""
err() { printf '::error::%s\n' "$1" >&2; fail=1; }

lista="${MTS_LISTA_SCRIPTS_INSTALACION:-.github/scripts-instalacion-permitidos.txt}"
case "$lista" in
  /*|*..*) echo "ERROR: MTS_LISTA_SCRIPTS_INSTALACION debe ser relativa y sin '..': '$lista'."; exit 1 ;;
esac

# Los cuatro que npm, yarn y pnpm ejecutan solos al instalar. `prepare` entra
# aqui porque tambien corre en `npm install` sin argumentos, no solo al
# publicar, y es el que mas veces se pasa por alto.
GANCHOS="preinstall install postinstall prepare"

# ---------------------------------------------------------------- lockfiles
# Dos lockfiles significan dos arboles de dependencias distintos y una
# instalacion cuyo resultado depende de con que gestor se ejecute. Eso no se
# puede auditar: el arbol que revisaste no tiene por que ser el que se instalo.
comprobar_lockfile() {
  local dir="$1" nombre encontrados=0 cuales=""
  for l in package-lock.json yarn.lock pnpm-lock.yaml bun.lockb; do
    if [ -f "$dir/$l" ]; then
      encontrados=$((encontrados + 1))
      cuales="$cuales $l"
      case " $gestores " in *" $l "*) ;; *) gestores="$gestores $l" ;; esac
    fi
  done
  cuales="${cuales# }"
  nombre="${dir#./}"; [ "$nombre" = "." ] && nombre="(raiz)"

  if [ "$encontrados" -eq 0 ]; then
    # Solo la raiz tiene que tener uno. En un monorepo con workspaces el
    # lockfile es UNO y vive en la raiz: exigirlo en cada paquete bloquearia
    # todos los monorepos, que es peor que no comprobarlo.
    if [ "$dir" = "." ]; then
      err "$nombre tiene package.json pero ningun lockfile.
    Sin lockfile la instalacion resuelve versiones nuevas en cada ejecucion, asi
    que lo que se reviso no es lo que se instala."
    else
      printf 'OK: %s sin lockfile propio (lo hereda de la raiz).\n' "$nombre"
    fi
  elif [ "$encontrados" -gt 1 ]; then
    err "$nombre tiene mas de un lockfile:$cuales
    Cada uno describe un arbol de dependencias distinto, y cual se aplica
    depende del gestor que se ejecute. Unificar antes de continuar."
  else
    printf 'OK: %s con un solo lockfile (%s).\n' "$nombre" "$cuales"
  fi
}

# ------------------------------------------------------- scripts de instalacion
# Un preinstall o un postinstall se ejecuta al instalar, con acceso a la red y
# sin que nadie lo lea. Ese fue el vector del incidente. Aqui solo se mira el
# package.json DEL REPOSITORIO: lo que hagan las dependencias se contiene con
# --ignore-scripts en la instalacion, que es cosa del workflow, no de esto.
comprobar_scripts() {
  local archivo="$1" nombre valor hallados=0
  nombre="${archivo#./}"
  # Falla cerrado, y basado en la LECTURA, no en el permiso: `test -r` devuelve
  # verdadero en Windows para archivos que luego no se pueden abrir. Sin esto,
  # un package.json ilegible dejaba la extraccion vacia y el control aprobaba
  # en silencio, que es el fail-open que la cabecera dice no tener.
  local contenido seccion
  if ! contenido=$(cat "$archivo" 2>/dev/null) || [ -z "$contenido" ]; then
    err "no se pudo leer $nombre, o esta vacio.
    Un control que no puede mirar no aprueba."
    return 0
  fi
  # Extraccion literal, sin interpretar el JSON: aqui solo interesa si la clave
  # existe dentro de "scripts". Un parser de mas seria una dependencia mas que
  # auditar, en un motor que existe justamente por una dependencia.
  seccion=$(printf '%s\n' "$contenido" | sed -n '/"scripts"[[:space:]]*:[[:space:]]*{/,/^[[:space:]]*}/p')
  for gancho in $GANCHOS; do
    valor=$(printf '%s\n' "$seccion" | grep -E "\"$gancho\"[[:space:]]*:" | head -1)
    [ -z "$valor" ] && continue

    hallados=$((hallados + 1))
    if [ -f "$lista" ] && grep -qxF "$nombre:$gancho" "$lista"; then
      printf 'OK: %s declara "%s", autorizado en %s.\n' "$nombre" "$gancho" "$lista"
      continue
    fi
    err "$nombre define el script de instalacion \"$gancho\":
    $(printf '%s' "$valor" | sed 's/^[[:space:]]*//')

    Se ejecuta solo al instalar, con acceso a la red y sin que nadie lo lea.
    Si es legitimo, declaralo en $lista con la linea exacta:
        $nombre:$gancho
    Un script de instalacion nunca deberia hacer falta para compilar: invoca la
    compilacion de forma explicita en su lugar."
  done
  # Un control que calla cuando pasa no se distingue de uno que no se ejecuto.
  [ "$hallados" -eq 0 ] && printf 'OK: %s sin scripts de instalacion.\n' "$nombre"
  return 0
}

recorrer() {
  local que="$1" encontrados=0
  # -prune sobre node_modules: los package.json de las dependencias no son
  # responsabilidad de este repositorio, y son decenas de miles.
  while IFS= read -r pj; do
    [ -z "$pj" ] && continue
    encontrados=$((encontrados + 1))
    case "$que" in
      lockfile) comprobar_lockfile "$(dirname "$pj")" ;;
      scripts)  comprobar_scripts "$pj" ;;
    esac
  done <<EOF
$(find . -name package.json -not -path './node_modules/*' -not -path '*/node_modules/*' -not -path './.git/*' 2>/dev/null)
EOF
  if [ "$encontrados" -eq 0 ]; then
    printf 'OK: no hay package.json; nada que comprobar (%s).\n' "$que"
  fi
}

# Un repositorio puede tener varios lockfiles legitimos (un front y un back
# independientes, por ejemplo), pero no de gestores DISTINTOS: entonces lo que
# se instala depende de con que comando se instale, y el arbol que alguien
# reviso no tiene por que ser el que acabo desplegado.
coherencia_de_gestor() {
  local n
  # gestores es una lista separada por espacios y contarla es justo lo que se
  # quiere; se usan los parametros posicionales en vez de un bucle con una
  # variable que no se lee, que era lo que shellcheck señalaba (SC2034).
  # shellcheck disable=SC2086
  set -- $gestores
  n=$#
  if [ "$n" -gt 1 ]; then
    err "el repositorio mezcla gestores de paquetes:$gestores
    Lo que se instala depende de con que comando se instale, asi que el arbol
    revisado no tiene por que ser el desplegado. Unificar en uno solo."
  elif [ "$n" -eq 1 ]; then
    printf 'OK: un solo gestor en todo el repositorio (%s).\n' "${gestores# }"
  fi
}

case "${1:-}" in
  --lockfile) recorrer lockfile; coherencia_de_gestor ;;
  --scripts)  recorrer scripts ;;
  --todo)     recorrer lockfile; coherencia_de_gestor; recorrer scripts ;;
  *) echo "Uso: $0 --lockfile | --scripts | --todo"; exit 1 ;;
esac

if [ "$fail" -ne 0 ]; then
  echo ""
  echo "Recuerda: CI=true NO equivale a --ignore-scripts. Son cosas distintas y"
  echo "confundirlas deja el agujero abierto entero."
  exit 1
fi
exit 0
