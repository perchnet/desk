#!/usr/bin/env bash
set -euxo pipefail

# maketmp dir
TEMP_DIR=$(mktemp -d)
cd "${TEMP_DIR}"

GOOD_WINBOX_URL="https://download.mikrotik.com/routeros/winbox/4.0beta29/WinBox_Linux.zip"
URL="${GOOD_WINBOX_URL}"
ZIPFile="winbox.zip"
try_get_winbox() {
k   # Fetch MikroTik downloads page
    html=$(wget -qO - "https://mikrotik.com/download")

    # Extract the WinBox_Linux.zip link
    download_url=$(echo "${html}" | grep -Eo 'https://[^"]*WinBox_Linux\.zip' | head -n 1)

    if [[ -n "${download_url}" ]]; then
        echo "Download URL: \"${download_url}\""
        export ZIPFile="${download_url}"
    fi
}
curl -L "${URL}" -o "${ZIPFile}"
unzip "${ZIPFile}"
tee winbox.desktop <<EOF
[Desktop Entry]
Type=Application
Version=1.0
Name=WinBox
Comment=GUI administration for Mikrotik RouterOS
Exec=/usr/bin/env --unset=QT_QPA_PLATFORM /usr/bin/WinBox
Icon=winbox
Terminal=false
Categories=Utility
StartupWMClass=winbox
EOF
srcdir="$(pwd)"
pkgdir="/"
install -D -m0755 "${srcdir}/WinBox" "${pkgdir}/usr/bin/WinBox"
install -D -m0644 "${srcdir}/assets/img/winbox.png" "${pkgdir}/usr/share/pixmaps/winbox.png"
install -D -m0644 "${srcdir}/winbox.desktop" "${pkgdir}/usr/share/applications/winbox.desktop"
rm -fR "${TEMP_DIR}" "${srcdir}"
