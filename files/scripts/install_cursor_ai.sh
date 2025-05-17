#!/usr/bin/bash
set -euxo pipefail
CURSOR_API_URL="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=latest"
CURSOR_URL="$(curl -L "${CURSOR_API_URL}" | jq -r .downloadUrl)"
echo "Downloading Cursor AppImage..."
tmpdir="$(mktemp -d)"
cd "${tmpdir}"
curl -L "${CURSOR_URL}" -o cursor.appimage
chmod +x cursor.appimage
./cursor.appimage --appimage-extract
cp -R squashfs-root/usr /
