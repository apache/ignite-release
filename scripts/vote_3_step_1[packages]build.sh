#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
set -o errtrace
set -o functrace


chmod +x release.properties
. ./release.properties


#
# Build RPM packages
#
if [ -d packaging ]; then
	rm -rf packaging
fi
cp -rfv git/packaging ./
cp -rfv svn/vote/apache-ignite-fabric-${ignite_version}-bin.zip packaging/
bash packaging/package.sh --rpm


#
# Build DEB packages
#
bash packaging/package.sh --deb


#
# Sign RPM packages
#
rpm --define "_gpg_name $(gpg --list-keys | grep uid | sed -r 's|uid\ +(.*)|\1|')" --addsign packaging/*.rpm


#
# Sign DEB packages
#
dpkg-sig -k $(gpg --list-keys | grep "^pub" | head -1 | cut -f2 -d / | cut -f1 -d" ") --sign builder packaging/*.deb


#
# Prepare SVN import directory
#
mkdir -pv packaging/pkg
mv -fv packaging/{*.rpm,*.deb} packaging/pkg

