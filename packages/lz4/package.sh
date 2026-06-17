#!/usr/bin/env bash

build() {
    make BUILD_STATIC=no PREFIX=/usr
}

install() {
    make BUILD_STATIC=no PREFIX=/usr install
}

"$LX_STAGE"
