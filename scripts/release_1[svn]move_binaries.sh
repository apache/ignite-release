#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
set -o errtrace
set -o functrace


chmod +x release.properties
. ./release.properties


echo "# Releasing ${ignite_version}${rc_name} :: Binaries #"
# Uncomment subsequent line in case you want to remove incorrectly released vote
#svn rm -m "Removing redundant Release" https://dist.apache.org/repos/dist/release/ignite/$ignite_version || true
svn mv https://dist.apache.org/repos/dist/dev/ignite/${ignite_version}${rc_name} \
       https://dist.apache.org/repos/dist/release/ignite/${ignite_version} \
    -m "Release ${ignite_version}: Binaries"
echo


#
# Output result and notes
#
echo "========================================================="
echo "Artifacts should be moved to Apache Ignite's release site"
echo "Please check results at:"
echo " * binaries: https://apache.org/dist/ignite/${ignite_version}"

