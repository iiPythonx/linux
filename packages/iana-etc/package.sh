#!/usr/bin/env bash

build() {
    return 0
}

install() {
    cp services protocols /etc
}

"$LX_STAGE"
