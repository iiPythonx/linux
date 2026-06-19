#!/usr/bin/env bash

build() {
    SRCDIR=$(pwd)

    cd unix
    ./configure --prefix=/usr           \
                --mandir=/usr/share/man \
                --disable-rpath

    make

    sed -e "s|$SRCDIR/unix|/usr/lib|" \
        -e "s|$SRCDIR|/usr/include|"  \
        -i tclConfig.sh

    sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.13|/usr/lib/tdbc1.1.13|" \
        -e "s|$SRCDIR/pkgs/tdbc1.1.13/generic|/usr/include|"     \
        -e "s|$SRCDIR/pkgs/tdbc1.1.13/library|/usr/lib/tcl8.6|"  \
        -e "s|$SRCDIR/pkgs/tdbc1.1.13|/usr/include|"             \
        -i pkgs/tdbc1.1.13/tdbcConfig.sh

    sed -e "s|$SRCDIR/unix/pkgs/itcl4.3.7|/usr/lib/itcl4.3.7|" \
        -e "s|$SRCDIR/pkgs/itcl4.3.7/generic|/usr/include|"    \
        -e "s|$SRCDIR/pkgs/itcl4.3.7|/usr/include|"            \
        -i pkgs/itcl4.3.7/itclConfig.sh

    unset SRCDIR
}

package() {
    cd unix
    make DESTDIR=$LX_ROOTFS install
    chmod 644 /usr/lib/libtclstub8.6.a
    chmod -v u+w /usr/lib/libtcl8.6.so
    make DESTDIR=$LX_ROOTFS install-private-headers
    ln -sfv tclsh8.6 /usr/bin/tclsh
    mv -v /usr/share/man/man3/{Thread,Tcl_Thread}.3
}