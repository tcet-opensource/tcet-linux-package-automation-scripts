#!/bin/env bash

cleanup() {
    echo
    print_message4 "Cleaning up..."
    rm -rf tcet-linux*
    exit 0
}

