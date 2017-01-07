#!/bin/bash -e

function initialize {
    # Package can be "installed" or "unpacked"
    status=`nami inspect $1`
    if [[ "$status" == *'"lifecycle": "unpacked"'* ]]; then
        # Clean up inputs
        inputs=""
        if [[ -f /$1-inputs.json ]]; then
            inputs=--inputs-file=/$1-inputs.json
        fi
        nami initialize $1 $inputs
    fi
}

# Set default values
export EMERSONDB_ROOT_PASSWORD=${EMERSONDB_ROOT_PASSWORD:-}
export EMERSONDB_USER=${EMERSONDB_USER:-}
export EMERSONDB_PASSWORD=${EMERSONDB_PASSWORD:-}
export EMERSONDB_DATABASE=${EMERSONDB_DATABASE:-}
export EMERSONDB_PORT=${EMERSONDB_PORT:-}
export EMERSONDB_REPLICATION_MODE=${EMERSONDB_REPLICATION_MODE:-}
export EMERSONDB_REPLICATION_USER=${EMERSONDB_REPLICATION_USER:-}
export EMERSONDB_REPLICATION_PASSWORD=${EMERSONDB_REPLICATION_PASSWORD:-}
export EMERSONDB_MASTER_HOST=${EMERSONDB_MASTER_HOST:-}
export EMERSONDB_MASTER_PORT=${EMERSONDB_MASTER_PORT:-3306}
export EMERSONDB_MASTER_USER=${EMERSONDB_MASTER_USER:-root}
export EMERSONDB_MASTER_PASSWORD=${EMERSONDB_MASTER_PASSWORD:-}

if [[ "$1" == "nami" && "$2" == "start" ]] ||  [[ "$1" == "/init.sh" ]]; then
    initialize emersondb
    echo "Starting application ..."
fi

exec /entrypoint.sh "$@"
