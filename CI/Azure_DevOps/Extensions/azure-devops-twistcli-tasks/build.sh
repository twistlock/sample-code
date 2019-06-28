#!/bin/bash

build() {
    if [[ ! -d node_modules ]]; then
        echo "Installing dependencies"
        npm install
    fi

    for task in tasks/*; do
        echo "Building task ${task}"
    
        pushd . &> /dev/null && cd "$task"
        if [[ ! -d node_modules ]]; then
            echo "Installing dependencies"
            npm install
        fi
    
        tsc
        popd &> /dev/null
    done
    
    tfx extension create --manifest-globs vss-extension.json
}

publish() {
    tfx extension publish --manifest-globs vss-extension.json --share-with "${ACCOUNT}" --token "${ACCESS_TOKEN}" --no-prompt --json
}

usage() {
    echo "${0} [bp]"
}

while getopts ":bp" opt; do
    case "${opt}" in
        b)
            build
            ;;
        p)
            publish
            ;;
        ?)
            usage
            ;;
    esac
done
