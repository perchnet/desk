#!/usr/bin/env bash
set -euxo pipefail

shopt -s nullglob
optdirs=(/opt/*)
if [[ -n "${optdirs[*]}" ]]; then
    optfix_dir="/usr/lib/bluebuild-optfix"
    mkdir -pv "${optfix_dir}"
    echo "Creating symlinks to fix packages that installed to /opt:"
    for optdir in "${optdirs[@]}"; do
        opt=$(basename "${optdir}")
        lib_opt_dir="${optfix_dir}/${opt}"
        mv -v "${optdir}" "${lib_opt_dir}"
        echo "linking ${optdir} => ${lib_opt_dir}"
        echo "L  ${optdir}  -  -  -  -  ${lib_opt_dir}" | tee "/usr/lib/tmpfiles.d/bluebuild-optfix-${opt}.conf"
    done
fi
