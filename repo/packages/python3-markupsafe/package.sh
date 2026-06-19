#!/usr/bin/env bash

build() {
    pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
}

package() {
    pip3 install --root-user-action ignore --no-index --find-links dist Markupsafe
}
