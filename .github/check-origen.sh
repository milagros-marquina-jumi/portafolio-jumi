#!/usr/bin/env bash
# La rama principal solo recibe pull requests desde las ramas autorizadas.
#
#   bash scripts/check-origen.sh <rama-principal> <origenes-permitidos>
#
# GitHub no sabe restringir la rama de ORIGEN de un pull request: los rulesets
# solo miran la rama de destino. La unica forma de imponerlo es un check que
# falle, asi que el job que ejecuta este script tiene que estar marcado como
# status check obligatorio.
#
# Limitacion honesta: esto no impide ABRIR el PR, impide MEZCLARLO.
#
# Los nombres de rama son datos del proyecto, no del motor: se reciben como
# argumentos. <origenes-permitidos> es una lista separada por espacios o comas.
#
# Lee del entorno de GitHub Actions:
#   GITHUB_EVENT_NAME, GITHUB_BASE_REF, GITHUB_HEAD_REF, GITHUB_REPOSITORY
#   MTS_REPO_ORIGEN   (github.event.pull_request.head.repo.full_name)

set -uo pipefail
export LC_ALL=C

principal="${1:-}"
permitidas_raw="${2:-}"
[ -n "$principal" ] || { echo "::error::Uso: $0 <rama-principal> <origenes-permitidos>"; exit 1; }
[ -n "$permitidas_raw" ] || { echo "::error::No se declaro ninguna rama de origen permitida."; exit 1; }

# Comas o espacios, indistintamente: 'develop,release' y 'develop release'.
permitidas=$(printf '%s' "$permitidas_raw" | tr ',' ' ')

evento="${GITHUB_EVENT_NAME:-}"
destino="${GITHUB_BASE_REF:-}"
origen="${GITHUB_HEAD_REF:-}"
repo="${GITHUB_REPOSITORY:-}"
repo_origen="${MTS_REPO_ORIGEN:-}"

if [ -z "$evento" ]; then
  echo "::error::GITHUB_EVENT_NAME vacio. No se puede verificar el origen del PR."
  exit 1
fi

if [ "$evento" != "pull_request" ]; then
  echo "OK: evento '$evento', no es un pull request. Nada que comprobar."
  exit 0
fi

if [ "$destino" != "$principal" ]; then
  echo "OK: PR hacia '${destino:-desconocido}'. La restriccion solo aplica a $principal."
  exit 0
fi

if [ -z "$origen" ]; then
  echo "::error::No se pudo determinar la rama de origen del PR. No se puede verificar."
  exit 1
fi

# head_ref es solo el NOMBRE de la rama: un fork tambien puede tener una rama
# llamada 'develop', y sin esta comprobacion pasaria por la develop de este
# repositorio.
if [ -z "$repo" ]; then
  echo "::error::GITHUB_REPOSITORY vacio. No se puede comparar el repositorio de origen."
  exit 1
fi
if [ "$repo_origen" != "$repo" ]; then
  echo "::error::PR hacia $principal desde el fork '${repo_origen:-desconocido}'."
  echo "$principal solo acepta PR desde las ramas de $repo."
  exit 1
fi

for p in $permitidas; do
  if [ "$origen" = "$p" ]; then
    echo "OK: $principal recibe el PR desde '$origen'."
    exit 0
  fi
done

echo "::error::PR hacia $principal desde '$origen'. $principal solo acepta PR desde: $permitidas"
echo ""
echo "El flujo del repositorio es:"
echo "    feature/*  --PR-->  $permitidas  --PR-->  $principal"
echo ""
echo "Reapunta este PR (Edit, y cambia la rama base) y, cuando la rama de"
echo "integracion este lista, abre un PR hacia $principal."
exit 1
