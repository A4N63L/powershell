#!/bin/bash
# Comprueba un único puerto TCP del localhost de este entorno.

if [[ $# -ne 1 || ! $1 =~ ^[0-9]+$ ]]; then
    echo "Uso: $0 PUERTO (entero decimal de 1 a 65535)" >&2
    exit 2
fi

# Quitar ceros antes de convertir evita octales y desbordamientos.
puerto=${1#"${1%%[!0]*}"}
if [[ -z $puerto || ${#puerto} -gt 5 ]]; then
    echo "Error: el puerto debe estar entre 1 y 65535." >&2
    exit 2
fi
puerto=$((10#$puerto))
if (( puerto < 1 || puerto > 65535 )); then
    echo "Error: el puerto debe estar entre 1 y 65535." >&2
    exit 2
fi

if ! command -v nc >/dev/null 2>&1; then
    echo "Error: falta netcat-openbsd (nc)." >&2
    exit 2
fi

# -z intenta conectar sin enviar datos; -w limita la espera a 2 segundos.
detalle=$(nc -z -w 2 127.0.0.1 "$puerto" 2>&1)
resultado=$?
if (( resultado == 0 )); then
    echo "Puerto TCP $puerto en 127.0.0.1: ABIERTO"
    exit 0
elif (( resultado == 1 )) && [[ -z $detalle ]]; then
    echo "Puerto TCP $puerto en 127.0.0.1: CERRADO"
    exit 1
else
    echo "Error al ejecutar nc (código $resultado): $detalle" >&2
    exit 2
fi
