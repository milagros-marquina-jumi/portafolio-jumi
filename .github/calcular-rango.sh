#!/usr/bin/env bash
# Decide que rango de commits se revisa. Imprime el rango en stdout.
#
#   bash scripts/calcular-rango.sh <sha-base>
#
# Imprime 'HEAD' cuando no hay una base utilizable. Ese fallback es
# deliberadamente conservador: revisar el historial completo es mas lento y
# puede rechazar una rama nueva por un correo antiguo ya no autorizado; se
# prefiere eso a no revisar nada.
#
# Los avisos van a stderr para no contaminar el valor que se captura.

set -uo pipefail
export LC_ALL=C

base="${1:-}"
vacio="0000000000000000000000000000000000000000"

usar_todo() {
  echo "::warning::$1 Se revisa el historial completo." >&2
  printf 'HEAD\n'
  exit 0
}

if [ -z "$base" ] || [ "$base" = "$vacio" ]; then
  usar_todo "Sin commit base (rama nueva o primer push)."
fi
if ! git cat-file -e "$base^{commit}" 2>/dev/null; then
  usar_todo "El commit base $base no existe en este clon."
fi
# Tras un force-push o una reescritura, base..HEAD daria un conjunto
# arbitrario de commits, asi que no se usa.
if ! git merge-base --is-ancestor "$base" HEAD 2>/dev/null; then
  usar_todo "El commit base $base no es ancestro de HEAD (historial reescrito o force-push)."
fi

printf '%s..HEAD\n' "$base"
