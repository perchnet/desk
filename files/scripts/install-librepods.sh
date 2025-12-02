#!/usr/bin/env bash
set -euxo pipefail
curl -fsSL https://nightly.link/kavishdevar/librepods/workflows/ci-linux-rust/linux%2Frust/librepods.zip -o /tmp/librepods.zip
unzip /tmp/librepods.zip -d /usr/bin/
echo "Creating systemd service for librepods"
tee /usr/lib/systemd/user/librepods.service << 'EOF'
[Unit]
Description=Librepods Service
Requires=bluetooth.target
After=bluetooth.target

[Service]
Type=exec
ExecStart=/usr/bin/librepods
Restart=always

[Install]
WantedBy=default.target
EOF
librepods --version