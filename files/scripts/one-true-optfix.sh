#!/usr/bin/env bash
set -euxo pipefail

# Check if /var/opt exists, if not create it
[[ ! -d "/var/opt" ]] && mkdir -p "/var/opt"

print "Creating symlinks to fix packages that installed to /opt:"
for optdir in /opt/*; do
    opt=$(basename "$optdir")
    lib_dir="$LIB_OPT_DIR/$opt"
    var_opt_dir="$VAR_OPT_DIR/$opt"
    mkdir -p "$lib_dir"
    ln -sf "$lib_dir" "$var_opt_dir"
    echo "Created symlinks for $opt"
    tee /usr/lib/tmpfiles.d/$opt.conf <<EOF
# create a link from $optdir to $lib_dir
L  $optdir  -  -  -  -  $lib_dir
EOF
done
