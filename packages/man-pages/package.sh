#!/usr/bin/env bash

build() {
    rm -v man3/crypt*
}

package() {
    make -R GIT=false prefix=/usr install
}