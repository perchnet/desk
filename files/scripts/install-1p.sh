#!/usr/bin/env bash

set -ouex pipefail

# Must be over 1000
GID_ONEPASSWORD="${GID_ONEPASSWORD:-1500}"

# Must be over 1000
GID_ONEPASSWORDCLI="${GID_ONEPASSWORDCLI:-1600}"

# And then we do the hacky dance!
mv /opt/1Password /usr/lib/1Password # move this over here

# Create a symlink /usr/bin/1password => /usr/lib/1Password/1password
rm /usr/bin/1password
ln -s /usr/lib/1Password/1password /usr/bin/1password

cd /usr/lib/1Password

# chrome-sandbox requires the setuid bit to be specifically set.
# See https://github.com/electron/electron/issues/17972
chmod 4755 /usr/lib/1Password/chrome-sandbox

# Normally, after-install.sh would create a group,
# "onepassword", right about now. But if we do that during
# the ostree build it'll disappear from the running system!
# I'm going to work around that by hardcoding GIDs and
# crossing my fingers that nothing else steps on them.
# These numbers _should_ be okay under normal use, but
# if there's a more specific range that I should use here
# please submit a PR!

# Specifically, GID must be > 1000, and absolutely must not
# conflict with any real groups on the deployed system.
# Normal user group GIDs on Fedora are sequential starting
# at 1000, so let's skip ahead and set to something higher.

# BrowserSupport binary needs setgid. This gives no extra permissions to the binary.
# It only hardens it against environmental tampering.
BROWSER_SUPPORT_PATH="/usr/lib/1Password/1Password-BrowserSupport"


# Add .desktop file and icons
if [ -d /usr/share/applications ]; then
# xdg-desktop-menu will only be available if xdg-utils is installed, which is likely but not guaranteed
if [ -n "$(which xdg-desktop-menu)" ]; then
  xdg-desktop-menu install --mode system --novendor /usr/lib/1Password/resources/1password.desktop
  xdg-desktop-menu forceupdate
else
  install -m0644 /usr/lib/1Password/resources/1password.desktop /usr/share/applications
fi
fi
if [ -d /usr/share/icons ]; then
cp -rf /usr/lib/1Password/resources/icons/* /usr/share/icons/
# Update icon cache
gtk-update-icon-cache -f -t /usr/share/icons/hicolor/
fi

chgrp "${GID_ONEPASSWORD}" "${BROWSER_SUPPORT_PATH}"
chmod g+s "${BROWSER_SUPPORT_PATH}"

# onepassword-cli also needs its own group and setgid, like the other helpers.
chgrp "${GID_ONEPASSWORDCLI}" /usr/bin/op
chmod g+s /usr/bin/op

# Dynamically create the required groups via sysusers.d
# and set the GID based on the files we just chgrp'd
cat >/usr/lib/sysusers.d/onepassword.conf <<EOF
g onepassword ${GID_ONEPASSWORD}
EOF
cat >/usr/lib/sysusers.d/onepassword-cli.conf <<EOF
g onepassword-cli ${GID_ONEPASSWORDCLI}
EOF

# remove the sysusers.d entries created by onepassword RPMs.
# They don't magically set the GID like we need them to.
rm -f /usr/lib/sysusers.d/30-rpmostree-pkg-group-onepassword.conf
rm -f /usr/lib/sysusers.d/30-rpmostree-pkg-group-onepassword-cli.conf

# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
cat >/usr/lib/tmpfiles.d/onepassword.conf <<EOF
L  /opt/1Password  -  -  -  -  /usr/lib/1Password
EOF
