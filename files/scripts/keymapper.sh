#!/bin/bash
set -euxo pipefail
# Download and install houmain/keymapper latest rpm

# They conveniently name the files with the version in them, so we have to parse the releases and find the latest released file that ends in "Linux.rpm"

SUFFIX="Linux.rpm"
REPO="houmain/keymapper"
SEARCH_STRING="Linux-x86_64.rpm"
RELEASES_API(){
    local USAGE="Usage: RELEASES_API user/repo"
    local REPO="${1:?"${USAGE}"}"
    local URL="https://api.github.com/repos/${REPO}/releases/latest"
    curl -s "${URL}"
}
PARSE_FOR_LATEST(){
    local STDIN=$(</dev/stdin)
    local USAGE="Usage: RELEASES_API user/repo | PARSE_FOR_LATEST search_string"
    local PARSE_STRING='(.assets[].browser_download_url | select(. | contains("SEARCH_STRING")))'
    local SEARCH_STRING="${1:?"${USAGE}"}"
    jq -r "${PARSE_STRING//SEARCH_STRING/"${SEARCH_STRING}"}" <<<"${STDIN}"
}
rpm-ostree install "$(RELEASES_API "${REPO}" | PARSE_FOR_LATEST "${SEARCH_STRING}")"
