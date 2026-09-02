#!/usr/bin/env bash
# Verifica que author y committer de cada commit del rango esten declarados en
# la allowlist de correos del repositorio evaluado.
#
#   bash scripts/check-authors.sh <rango>        # p.ej. abc123..HEAD, o HEAD
#
# ESTO NO ES AUTENTICACION. Los campos author y committer de un commit son
# texto libre: se cambian con git config, con GIT_AUTHOR_EMAIL o con
# `git commit --author`. Este control detecta identidades mal configuradas y
# commits hechos con la cuenta equivocada; NO impide una suplantacion
# deliberada. Lo unico que prueba quien empujo es la autenticacion del push
# (clave SSH / token) y, para el contenido, la firma criptografica: eso se
# exige con "Require signed commits" en la proteccion de rama.
#
#   MTS_LISTA_AUTORES   allowlist de correos (def. .github/autores-permitidos.txt)
#
# Falla cerrado: si la lista no existe, esta vacia, tiene una entrada mal
# formada o git no puede recorrer el rango, sale 1.
#
# Compatible con bash 3.2 (macOS), Git Bash (Windows) y Ubuntu (CI).

set -uo pipefail
export LC_ALL=C

rango="${1:-}"
[ -n "$rango" ] || { echo "::error::Uso: $0 <rango>"; exit 1; }

permitidos="${MTS_LISTA_AUTORES:-.github/autores-permitidos.txt}"
case "$permitidos" in
  /*|*..*) echo "::error::MTS_LISTA_AUTORES debe ser relativa y sin '..': '$permitidos'."; exit 1 ;;
esac

if [ ! -f "$permitidos" ]; then
  echo "::error::Falta $permitidos. No se puede verificar la identidad."
  exit 1
fi

tmp=$(mktemp -d 2>/dev/null) || { echo "::error::mktemp fallo. No se puede verificar."; exit 1; }
trap 'rm -rf "$tmp"' EXIT

# Normalizacion: quita CR de archivos guardados en Windows, comentarios,
# lineas vacias y espacios alrededor.
tr -d '\r' < "$permitidos" \
  | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e '/^#/d' -e '/^$/d' \
  > "$tmp/permitidos.txt"
if [ ! -s "$tmp/permitidos.txt" ]; then
  echo "::error::$permitidos no tiene ningun correo valido."
  exit 1
fi
while IFS= read -r c; do
  case "$c" in
    *@*.*) ;;
    *) echo "::error::Entrada sin formato de correo en $permitidos: '$c'"; exit 1 ;;
  esac
done < "$tmp/permitidos.txt"

# git log a un archivo, con su estado de salida comprobado: dentro de
# `< <(git log ...)` un fallo se perderia y el bucle vacio terminaria
# imprimiendo "todos autorizados".
if ! git log --format='%ae%n%ce' "$rango" > "$tmp/correos.raw" 2>"$tmp/log.err"; then
  echo "::error::git log fallo sobre el rango '$rango'. No se puede verificar."
  sed 's/^/    /' "$tmp/log.err"
  exit 1
fi
tr -d '\r' < "$tmp/correos.raw" | sed '/^$/d' | sort -u > "$tmp/correos.txt"

# Comparacion insensible a mayusculas SIN `grep -i`: la combinacion -i -x -F
# aborta (senal 6) en GNU grep 3.0, que es el que trae Git Bash. Un grep que
# aborta devuelve "no encontrado" y rechazaria cada push. Se normaliza a
# minusculas y se compara literal.
tr 'A-Z' 'a-z' < "$tmp/permitidos.txt" > "$tmp/permitidos.lc"
fail=0
while IFS= read -r correo; do
  correo_lc=$(printf '%s' "$correo" | tr 'A-Z' 'a-z')
  grep -qxF -- "$correo_lc" "$tmp/permitidos.lc" \
    || { echo "::error::Identidad no autorizada en un commit del rango: $correo"; fail=1; }
done < "$tmp/correos.txt"

if [ "$fail" -ne 0 ]; then
  echo "Autorizados en $permitidos:"
  sed 's/^/    /' "$tmp/permitidos.txt"
  echo "Si es una identidad legitima (bot, merge de la interfaz de GitHub),"
  echo "agregala explicitamente a ese archivo; no uses patrones amplios."
  exit 1
fi

echo "OK: identidad configurada correcta en todos los commits del rango."
echo "    (recordatorio: esto no prueba quien empujo; eso lo dan la firma y la autenticacion del push)"
exit 0
