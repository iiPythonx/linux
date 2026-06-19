#!/usr/bin/env bash

build() {
    ./configure --prefix=/usr         \
                --libexecdir=/usr/lib \
                --with-secure-path    \
                --with-env-editor     \
                --docdir=/usr/share/doc/sudo-1.9.17p2 \
                --with-passprompt="[sudo] password for %p: " &&
    make
}

package() {
    make install
    cat > /etc/sudoers.d/00-sudo << "EOF"
Defaults secure_path="/usr/sbin:/usr/bin"
%wheel ALL=(ALL) ALL
EOF
}
