#!/usr/bin/env bash

chmod +x release.properties
. ./release.properties

echo "Releasing ${ignite_version}${rc_name}"

cd git

echo "Creating new tag..."
git tag -a $ignite_version -m "${ignite_version}"
git push origin $ignite_version

echo " "
echo "======================================================"
echo "Release tag should be created."
echo "Please check results at "
echo "https://git-wip-us.apache.org/repos/asf?p=ignite.git;a=tags"