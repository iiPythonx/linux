#!/usr/bin/env bash

build() {
    sed -i '/long long t1;/,+1s/()/(...)/' configure
    ./configure --prefix=/usr    \
                --enable-cxx     \
                --disable-static \
                --docdir=/usr/share/doc/gmp-6.3.0
    make
    make html
    make check 2>&1 | tee gmp-check-log
    awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
    echo "Ensure 199+ tests passed, if not then abort now!"
    sleep 10
}

install() {
    make install
    make install-html
}

"$LX_STAGE"
