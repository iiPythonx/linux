#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr
    make
}

install() {
    make install
}

"$LX_STAGE"
