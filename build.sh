# Copyright (c) 2026 iiPython

set -euo pipefail

# Environment
COMPILE_TARGET=x86_64-iipython-linux-gnu

# General path
BUILDDIR="$(realpath build)"
mkdir -p "$BUILDDIR"

TOOLDIR="$(realpath build/tools)"
mkdir -p "$TOOLDIR"

ROOTFS="$(realpath build/rootfs)"
mkdir -p "$ROOTFS"

# Utilities
package_exists() {
    local name="$1"
    local version="$2"

    jq -e --arg n "$name" --arg v "$version" \
        'has($n) and .[$n] == $v' \
        "$ROOTFS/var/lib/packages.json" >/dev/null
}

# Begin loading packages
install_package() {
    source "$1"
    if package_exists "$NAME" "$VERSION"; then
        echo "Skipping $NAME-$VERSION as it's already been installed"
        return
    fi

    # Fetch package source
    filename="${SOURCE##*/}"
    if [ ! -f "$SOURCES/$filename" ]; then
        curl -L -o "$SOURCES/$filename" "$SOURCE"
    fi

    # Extract
    if [ ! -d "$SOURCES/$NAME" ]; then
        mkdir "$SOURCES/$NAME"
        tar -xf "$SOURCES/$filename" \
            --strip-components=1 \
            -C "$SOURCES/$NAME"
    fi

    # Build and install
    pushd "$SOURCES/$NAME"
    build
    install
    popd

}

# Install toolchain
TOOLCHAIN_PACKAGES=(binutils)
for package in "${TOOLCHAIN_PACKAGES[@]}"; do
    python3 tools/lx.py \
        --root-dir "$ROOTFS" \
        --prefix "$TOOLDIR" \
        --temp-dir "$(realpath temp)" \
        --sources-dir "$(realpath packages)" \
        $package
done

# BASE_PACKAGES=(linux-headers m4)
# for package in "${BASE_PACKAGES[@]}"; do
#     python3 tools/lx.py \
#         --root-dir "$ROOTFS" \
#         --temp-dir "$(realpath temp)" \
#         --sources-dir "$(realpath packages)" \
#         $package
# done
