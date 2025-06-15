#!/usr/bin/env bash
#
set -euxo pipefail

# Note: Installing Google Chrome will add the Google repository so your system will automatically keep Google Chrome up to date. If you don’t want Google's repository, do “sudo touch /etc/default/google-chrome” before installing the package.
touch /etc/default/google-chrome
