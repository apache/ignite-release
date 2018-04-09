#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
set -o errtrace
set -o functrace


chmod +x release.properties
. ./release.properties


echo "RC ${ignite_version}${rc_name}"
# Uncomment subsequent line in case you want to remove incorrectly prepared RC
#svn rm -m "Removing redundant Release" https://dist.apache.org/repos/dist/dev/ignite/$ignite_version$rc_name || true
svn import svn/vote https://dist.apache.org/repos/dist/dev/ignite/$ignite_version$rc_name -m "New RC ${ignite_version}${rc_name}: Binaries"
svn import packaging/pkg https://dist.apache.org/repos/dist/dev/ignite/packages_$ignite_version$rc_name -m "New RC ${ignite_version}${rc_name}: Packages"


#
# Output result and notes
#
echo
echo "============================================================================="
echo "Artifacts should be moved to RC repository"
echo "Please check results at:"
echo " * binaries: https://dist.apache.org/repos/dist/dev/ignite/${ignite_version}${rc_name}"
echo " * packages: https://dist.apache.org/repos/dist/dev/ignite/packages_${ignite_version}${rc_name}"
