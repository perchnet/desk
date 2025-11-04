#!/usr/bin/env bash
set -euxo pipefail

#shellcheck source=../data/winbox/PKGBUILD
source /tmp/winbox/PKGBUILD
srcdir="/tmp/winbox/winbox"
cd "${srcdir}"

# defined in the PKGBUILD
URL="${source##*::}"
ZIPFile="${source%%::*}"

# Download and extract Winbox from the URL
curl -L "${URL}" -o "${ZIPFile}"
unzip "${ZIPFile}"
pkgdir="/"
# pkgdir="$(mktemp -d)"
set -x
package
rm -fR "${srcdir}"
