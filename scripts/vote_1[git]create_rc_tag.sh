#!/usr/bin/env bash

chmod +x release.properties
. ./release.properties

echo "Preparing vote ${ignite_version}${rc_name}"

cd git

echo "Removing obsolete tag..."
echo $ignite_version
echo $rc_name

git fetch --tags 
git tag -d $ignite_version$rc_name
git push origin :refs/tags/$ignite_version$rc_name

git status

echo "Creating new tag..."
git tag -a $ignite_version$rc_name -m "${ignite_version}${rc_name}"
git push origin $ignite_version$rc_name

echo " "
echo "======================================================"
echo "RC tag should be created."
echo "Please check results at "
echo "https://git-wip-us.apache.org/repos/asf?p=ignite.git;a=tags"