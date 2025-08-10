#!/usr/bin/env bash
set -euxo pipefail

mkdir -p "/var/opt"

echo "Creating symlinks to fix packages that installed to /opt:"
for optdir in /opt/*; do
    opt=$(basename "$optdir")
    lib_opt_dir="/usr/lib/opt/$opt"
    mv "$optdir" "$lib_opt_dir"
    mkdir -p "$lib_opt_dir"
    tee /usr/lib/tmpfiles.d/$opt.conf <<EOF
# create a link from $optdir to $lib_opt_dir
L  $optdir  -  -  -  -  $lib_opt_dir
EOF
done
