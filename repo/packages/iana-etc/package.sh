#!/usr/bin/env bash

build() {
    return 0
}

package() {
    cp services protocols /etc
}