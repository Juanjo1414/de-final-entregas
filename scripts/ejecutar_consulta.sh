#!/usr/bin/env bash
# Ejecuta una consulta de Athena en el workgroup del ejercicio, guarda el resultado
# como CSV y registra la ejecución en evidencias/ejecuciones_athena.csv.
# Uso: bash scripts/ejecutar_consulta.sh <etapa> <archivo_sql> <archivo_resultado> [numero_de_sentencia]
set -euo pipefail
cd "$(dirname "$0")/.."

etapa=$1
archivo_sql=$2
archivo_resultado=$3
sentencia=${4:-1}
workgroup=${WORKGROUP:-entregas_wg}
base_datos=${BASE_DATOS:-entregas_db}
registro=evidencias/ejecuciones_athena.csv

# Se toma la sentencia pedida (separadas por ;) y se quitan las líneas de comentario
consulta=$(awk -v n="$sentencia" 'BEGIN{RS=";"} NR==n' "$archivo_sql" | grep -v '^[[:space:]]*--' | sed '/^[[:space:]]*$/d')
if [ -z "$consulta" ]; then
    echo "No se encontró la sentencia $sentencia en $archivo_sql" >&2
    exit 1
fi

id_ejecucion=$(aws athena start-query-execution \
    --work-group "$workgroup" \
    --query-execution-context Database="$base_datos" \
    --query-string "$consulta" \
    --query QueryExecutionId --output text)
echo "Ejecución $id_ejecucion iniciada ($archivo_sql, sentencia $sentencia)"

while true; do
    estado=$(aws athena get-query-execution --query-execution-id "$id_ejecucion" \
        --query QueryExecution.Status.State --output text)
    case "$estado" in
        SUCCEEDED) break ;;
        FAILED|CANCELLED)
            aws athena get-query-execution --query-execution-id "$id_ejecucion" \
                --query QueryExecution.Status.StateChangeReason --output text >&2
            exit 1 ;;
        *) sleep 2 ;;
    esac
done

# Athena escribe el CSV con comillas; los valores no tienen comas, así que se quitan
ubicacion=$(aws athena get-query-execution --query-execution-id "$id_ejecucion" \
    --query QueryExecution.ResultConfiguration.OutputLocation --output text)
mkdir -p "$(dirname "$archivo_resultado")"
aws s3 cp "$ubicacion" - | sed 's/"//g' > "$archivo_resultado"

if [ ! -f "$registro" ]; then
    echo "etapa,archivo_sql,id_ejecucion,archivo_resultado" > "$registro"
fi
echo "$etapa,$archivo_sql,$id_ejecucion,$archivo_resultado" >> "$registro"

echo "Resultado guardado en $archivo_resultado:"
cat "$archivo_resultado"
