#!/usr/bin/env bash
# Copyright (c) 2026 iiPython

: "${ROOTFS:=$(realpath rootfs)}"

sudo umount -R "$ROOTFS"/run
sudo umount -R "$ROOTFS"/sys
sudo umount -R "$ROOTFS"/proc
sudo umount -R "$ROOTFS"/dev
