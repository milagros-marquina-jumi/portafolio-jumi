#!/usr/bin/env bash
# Restaura la configuracion local de seguridad desde la rama base del PR.
#
#   bash scripts/restaurar-config-base.sh <sha-base> [archivo...]
#
# POR QUE: centralizar el motor no elimina el problema de la configuracion
# local. Las listas siguen viviendo en el repositorio evaluado y un pull
# request puede modificarlas: anadirse a autores-permitidos.txt, ampliar
# ejecutables-permitidos.txt o excluirse por .scanignore, y despues pedirle a
# esa misma version que lo apruebe.
#
# El motor viene de un commit inmutable de otro repositorio, asi que un PR no
# puede tocarlo; la configuracion no es inmune por si sola, y por eso se lee
# desde la base.
#
# Consecuencia deliberada: cambiar un archivo de configuracion exige un PR
# propio, revisado (CODEOWNERS), y mezclado antes que el cambio que lo
# necesita.
#
# Falla cerrado: si el SHA base no existe en el clon, aborta. Un checkout con
# fetch-depth insuficiente no puede pasar por "no habia nada que restaurar".

set -uo pipefail
export LC_ALL=C

base="${1:-}"
[ -n "$base" ] || { echo "::error::Uso: $0 <sha-base> [archivo...]"; exit 1; }
shift

if [ "$#" -eq 0 ]; then
  set -- .github/autores-permitidos.txt .github/ejecutables-permitidos.txt .scanignore
fi

if ! git cat-file -e "$base^{commit}" 2>/dev/null; then
  echo "::error::El commit base $base no existe en este clon."
  echo "El checkout necesita fetch-depth: 0 y la rama base traida con git fetch."
  exit 1
fi

# El diff se captura ANTES de restaurar, y entre COMMITS (base..HEAD), no
# contra el arbol de trabajo.
#
# Antes se calculaba despues del `git checkout`, que reescribe el archivo en el
# arbol y en el indice: para entonces el archivo ya coincidia con la base y
# desaparecia del diff. Resultado: un PR que se anadia a autores-permitidos.txt
# quedaba correctamente neutralizado, pero SIN el aviso que lo hacia visible en
# la revision. La proteccion funcionaba; la evidencia se borraba sola, que en
# un control de seguridad es casi peor, porque parece que no paso nada.
if ! cambiados=$(git diff --name-only "$base" HEAD -- \
      "$@" .github/workflows/ .githooks/ 2>/dev/null); then
  echo "::error::No se pudo comparar $base con HEAD. No se puede verificar."
  exit 1
fi

for f in "$@"; do
  case "$f" in
    /*|*..*) echo "::error::Ruta de configuracion invalida: '$f'."; exit 1 ;;
  esac
  if git cat-file -e "$base:$f" 2>/dev/null; then
    if git checkout "$base" -- "$f"; then
      echo "  restaurado desde la base: $f"
    else
      echo "::error::No se pudo restaurar $f desde $base. No se puede verificar."
      exit 1
    fi
  else
    echo "  (no existe en la base, se omite: $f)"
  fi
done

# Aviso visible si el PR toca archivos de control. No lo bloquea este script,
# lo bloquea la revision obligatoria de CODEOWNERS: fallar aqui impediria
# incluso corregir un control roto.
if [ -n "$cambiados" ]; then
  echo "::warning::Este PR modifica archivos de control de seguridad; exige revision de CODEOWNERS:"
  printf '%s\n' "$cambiados" | sed 's/^/    /'
fi

exit 0
