#!/usr/bin/env bash

build() {
    make BUILD_STATIC=no PREFIX=/usr
}

package() {
    make BUILD_STATIC=no PREFIX=/usr install
}
