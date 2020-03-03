#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
set -o errtrace
set -o functrace


chmod +x release.properties
. ./release.properties


#
# Check GPG requirements
#
if [ "$(gpg --version | head -1 | sed -r 's|^.*([0-9]+)\.[0-9]+\.[0-9]+$|\1|')" != "2" ]; then
    echo "[ERROR] Wrong GPG version: $(gpg --version | head -1), have to be 2.x and higher"
    exit 1
fi
gpg_key="$(gpg --list-keys | grep -C1 "^pub" | tail -1 | sed -r 's|^\ +||')"


#
# Build packages
#
if [ -d packaging ]; then
    rm -rf packaging
fi
cp -rfv git/packaging ./
cp -rfv svn/vote/apache-ignite-${ignite_version}-bin.zip packaging/
bash packaging/package.sh --rpm
bash packaging/package.sh --deb


#
# Sign packages
#
rpm --define "_gpg_name ${gpg_key}" --addsign packaging/*.rpm
dpkg-sig -k ${gpg_key} --sign builder packaging/*.deb


#
# Prepare SVN import directory
#
mkdir -pv packaging/pkg
mv -fv packaging/{*.rpm,*.deb} packaging/pkg

