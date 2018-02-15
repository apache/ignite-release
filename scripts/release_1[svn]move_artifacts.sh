#!/usr/bin/env bash

chmod +x release.properties
. ./release.properties

echo "Releasing ${ignite_version}${rc_name}"

#uncomment subsequent line in case you want to remove incorrectly released vote
#svn rm -m "Removing redundant Release" https://dist.apache.org/repos/dist/release/ignite/$ignite_version || true
svn mv https://dist.apache.org/repos/dist/dev/ignite/${ignite_version}${rc_name} https://dist.apache.org/repos/dist/release/ignite/${ignite_version} -m "Release ${ignite_version}: Binaries"
svn mv https://dist.apache.org/repos/dist/dev/ignite/rpm_${ignite_version}${rc_name} https://dist.apache.org/repos/dist/release/ignite/rpm -m "Release ${ignite_version}: RPMs"

echo "Please check results..."

echo " "
echo "======================================================"
echo "Artifacts should be moved to release repository"
echo "Please check results at"
echo "https://dist.apache.org/repos/dist/release/ignite/"
