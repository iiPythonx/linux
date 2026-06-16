#!/usr/bin/env bash

build() {
    rm -v man3/crypt*
}

install() {
    make -R GIT=false prefix=/usr install
}

"$LX_STAGE"
