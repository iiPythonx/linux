#!/usr/bin/env bash

build() {
    [[ ! -z "${LX_EXTRA_BOOTSTRAP}" ]] && sed '6031s/$add_dir//' -i ltmain.sh
    mkdir build && cd build
    if [[ ! -z "${LX_EXTRA_BOOTSTRAP}" ]]; then
        ../configure                   \
            --prefix=/usr              \
            --build=$(../config.guess) \
            --host=$LX_TARGET          \
            --disable-nls              \
            --enable-shared            \
            --enable-gprofng=no        \
            --disable-werror           \
            --enable-64-bit-bfd        \
            --enable-new-dtags         \
            --enable-default-hash-style=gnu
            make
    else
        ../configure --prefix=/usr      \
                    --sysconfdir=/etc   \
                    --enable-ld=default \
                    --enable-plugins    \
                    --enable-shared     \
                    --disable-werror    \
                    --enable-64-bit-bfd \
                    --enable-new-dtags  \
                    --with-system-zlib  \
                    --enable-default-hash-style=gnu
        make tooldir=/usr
        make -k check || true
    fi
}

package() {
    cd build
    if [[ -n "${LX_EXTRA_BOOTSTRAP}" ]]; then
        make DESTDIR=$LX_ROOTFS install
        rm -v $LX_ROOTFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}
    else
        make tooldir=/usr install
        rm -rfv /usr/lib/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a /usr/share/doc/gprofng/
    fi
}