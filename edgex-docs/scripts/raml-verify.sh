#!/bin/sh
set -e

exitCode=0

RAML_FILE_PATH=${RAML_FILE_PATH:-./api/raml}

for RAML_FILE in $(find ${RAML_FILE_PATH} -type f); do
  echo "Verifying ${RAML_FILE}..."
  raml2html ${RAML_FILE} -o /dev/null && echo OK || exitCode=1;
done

exit ${exitCode}