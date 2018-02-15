#!/usr/bin/env bash

chmod +x release.properties
. ./release.properties

echo "RC ${ignite_version}${rc_name}"

#uncomment subsequent line in case you want to remove incorrectly prepared RC
#svn rm -m "Removing redundant Release" https://dist.apache.org/repos/dist/dev/ignite/$ignite_version$rc_name || true
svn import svn/vote https://dist.apache.org/repos/dist/dev/ignite/$ignite_version$rc_name -m "New RC ${ignite_version}${rc_name}: Binaries"
svn import rpm https://dist.apache.org/repos/dist/dev/ignite/rpm_$ignite_version$rc_name -m "New RC ${ignite_version}${rc_name}: RPMs"

echo "Please check results..."

echo " "
echo "======================================================"
echo "Artifacts should be moved to RC repository"
echo "Please check results at"
echo "https://dist.apache.org/repos/dist/dev/ignite/"
