#!/usr/bin/env bash

chmod +x release.properties
. ./release.properties

REPO_ROOT="rpm/$(echo ${ignite_version} | cut -f1 -d.).x"

#
# Install required packages if necessary
#
if [ ! -f /usr/bin/rpm -o \
     ! -f /usr/bin/rpmsign -o \
     ! -f /usr/bin/createrepo -o \
     ! -f /usr/bin/gpg-connect-agent ]
then
    echo "# Installing requred packages #"
    sudo apt-get update
    sudo apt-get install rpm createrepo gnupg-agent --no-install-recommends -y
fi
echo

#
# Build package
#
echo "# Building RPM package #"
if [ ! -f rpmbuild ]; then rm -rf rpmbuild; fi
mkdir -pv rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
cp -rfv git/packaging/rpm/* rpmbuild
cp -rfv svn/vote/apache-ignite-fabric-${ignite_version}-bin.zip rpmbuild/SOURCES/apache-ignite.zip
rpmbuild -bb --define "_topdir $(pwd)/rpmbuild" rpmbuild/SPECS/apache-ignite.spec
echo

#
# Prepare repository root
#
echo "# Preparing repository root #"
if [ ! -f rpm ]; then rm -rf rpm; fi
mkdir -pv ${REPO_ROOT}
mv -v rpmbuild/RPMS/noarch/*.rpm ${REPO_ROOT}
echo

#
# Sign RPM
#
echo "# Signing RPM #"
rpm --define "_gpg_name $(gpg --list-keys | grep uid | sed -r 's|uid\ +(.*)|\1|')" --addsign ${REPO_ROOT}/*.rpm
echo

#
# Create repository layout
#
echo "# Creating repository layout #"
CREATEREPO=createrepo
grep -q "Microsoft" /proc/version && CREATEREPO="sudo ${CREATEREPO}"    # Detect Windows 10 WSL
${CREATEREPO} -v -p -s sha512 --update ${REPO_ROOT}

