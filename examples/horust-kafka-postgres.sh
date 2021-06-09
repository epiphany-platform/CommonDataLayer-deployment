#!/usr/bin/env bash
set -euo pipefail

cd cdl

if [[ $* == *--release* ]]
then
    cargo build --release
else
    cargo build
fi

cd ..

if [[ $* == *--clean* ]]
then
    if [[ $* == *--infra* ]]
    then
        docker-compose -f compose/docker-compose.yml down --remove-orphans
        sleep 3s
    fi
    rm -rf logs
    mkdir -p logs/postgres
fi
if [[ $* == *--infra* ]]
then
    docker-compose -f compose/docker-compose.yml up -d postgres kafka jaeger

    sleep 15s
fi

if [[ $* == *--release* ]]
then
export TARGET="release"
fi

export HORUST_LOG="info"
horust \
    --services-path ./bare/horust/kafka/base \
    --services-path ./bare/horust/kafka/postgres
