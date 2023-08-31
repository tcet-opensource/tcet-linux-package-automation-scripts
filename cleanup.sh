#!/bin/env bash

cleanup() {
    echo
    print_message4 "Cleaning up..."
    rm -rf tcet-linux*

    # Start cleanup loop
    while true; do
        if [ -d "tcet-linux*" ]; then
            echo
            print_message4 "Cleaning up..."
            rm -rf tcet-linux*
        else
            cd ..
        fi

        if [ -f "main.sh" ]; then
            print_message4 "Final cleaning..."
            rm -rf tcet-linux*
            break
        fi
    done

    exit 0
}

