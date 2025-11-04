#!/usr/bin/env bash
set -euxo pipefail

# maketmp dir
TEMP_DIR=$(mktemp -d)
cd "${TEMP_DIR}"

# get the WinBox AUR package, because that's the easiest way to check the latest version...
curl --retry 5 --retry-max-time 120 -L https://aur.archlinux.org/cgit/aur.git/snapshot/winbox.tar.gz | tar -xzv
cd winbox
source PKGBUILD

# "source=WinBox-4.0beta17.zip::https://download.mikrotik.com/routeros/winbox/4.0beta17/WinBox_Linux.zip"
URL="${source##*::}"
ZIPFile="${source%%::*}"
curl --retry 5 --retry-max-time 120 -L "${URL}" -o "${ZIPFile}"
unzip "${ZIPFile}"
srcdir="$(pwd)"
pkgdir="/"
# pkgdir="$(mktemp -d)"
set -x
package
rm -fR "${TEMP_DIR}" "${srcdir}"
