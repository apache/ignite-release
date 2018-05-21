#!/usr/bin/env bash

chmod +x release.properties
. ./release.properties

echo "Releasing ${ignite_version}${rc_name}"

rm -r fabric

unzip svn/vote/apache-ignite-fabric-*-bin.zip -d fabric

echo "Uploading to svn ..."

#uncomment subsequent line in case you want to remove incorrectly released vote
#svn rm -m "Removing redundant Release" https://svn.apache.org/repos/asf/ignite/site/trunk/releases/$ignite_version || true
svn import fabric/apache-ignite-fabric-$ignite_version-bin/docs https://svn.apache.org/repos/asf/ignite/site/trunk/releases/$ignite_version -m "new Release ($ignite_version)"
svn import fabric/apache-ignite-fabric-$ignite_version-bin/platforms/cpp/docs https://svn.apache.org/repos/asf/ignite/site/trunk/releases/$ignite_version/cppdoc -m "new Release (${ignite_version})"
svn import fabric/apache-ignite-fabric-$ignite_version-bin/platforms/dotnet/docs https://svn.apache.org/repos/asf/ignite/site/trunk/releases/$ignite_version/dotnetdoc -m "new Release (${ignite_version})"

echo " "
echo "======================================================"
echo "Documentation should be uploaded to site repository"
echo "Please check results at"
echo "https://svn.apache.org/repos/asf/ignite/site/trunk/releases"