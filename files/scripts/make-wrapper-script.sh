#!/bin/bash
# Create wrapper script
#
# This script will create a wrapper script, replacing the passed argument (a link) with a wrapper script that applies some flags.

USAGE="
Usage: ${0} <link> [flags...]
Examples:
  - ${0} /usr/bin/firefox --private-window
  - ${0} /usr/bin/firefox --private-window --new-tab https://example.com
  - ${0} /usr/bin/google-chrome --enable-features=UseOzonePlatform,TouchpadOverscrollHistoryNavigation --ozone-platform=wayland
"

LINK="${1:?"${USAGE}"}"
set -euo pipefail

# load the script template
# shellcheck disable=SC2016
SCRIPT='#!/bin/bash
# __SCRIPT__
exec __TARGET__ __FLAGS__ "$@"
'
if [ ! -L "${LINK}" ]; then
    echo "${LINK} is not a link, skipping..."
    return
fi
shift
if [ -n "${1:-}" ]; then # if additional flags are passed...
    FLAGS_SPLAT="$(printf "%q " "${@}")"
    else # no additional flags
    FLAGS_SPLAT=""
fi
TARGET=$(readlink -f "${LINK}")
# Replace links with a script that launches the browser with the correct flags:
SCRIPT="${SCRIPT//__TARGET__/"${TARGET}"}" # Substitute the target in
SCRIPT="${SCRIPT//__SCRIPT__/"${LINK}"}" # Replace the comment in the header, so we can identify the script
SCRIPT="${SCRIPT//__FLAGS__/"${FLAGS_SPLAT}"}" # Substitute the flags in
# echo "${SCRIPT}"
rm -f "${LINK}" # Remove the link
tee "${LINK}" <<<"$SCRIPT" # Write the script to the link
chmod +x "${LINK}" # Make the script executable
