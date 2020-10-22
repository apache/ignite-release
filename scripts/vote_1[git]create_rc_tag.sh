#!/usr/bin/env bash

chmod +x release.properties
. ./release.properties

echo "Preparing tag ${ignite_version}${rc_name}"

cd git

git remote set-url origin https://gitbox.apache.org/repos/asf/ignite.git

git fetch --tags

# Uncomment to remove tag with the same name
# echo "Removing obsolete tag..."
# git tag -d $ignite_version$rc_name
# git push origin :refs/tags/$ignite_version$rc_name

git status

echo "Creating new tag..."
git tag -a $ignite_version$rc_name -m "${ignite_version}${rc_name}"
git push origin $ignite_version$rc_name

echo " "
echo "======================================================"
echo "RC tag should be created."
echo "Please check results at "
echo "https://gitbox.apache.org/repos/asf?p=ignite.git;a=tags"