# Copyright (c) 2026 iiPython

set -euo pipefail

ROOTFS="$(realpath rootfs)"
mkdir -p "$ROOTFS"

BASE_PACKAGES=(m4)
for package in "${BASE_PACKAGES[@]}"; do
    python3 tools/lx.py \
        --root-dir "$ROOTFS" \
        --temp-dir "$(realpath temp)" \
        --sources-dir "$(realpath packages)" \
        --config-dir "$ROOTFS/var/lx" \
        $package
done
