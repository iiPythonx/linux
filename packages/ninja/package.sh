#!/usr/bin/env bash

build() {
    python3 configure.py --bootstrap --verbose
}

package() {
    install -vm755 ninja /usr/bin/
    install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
}