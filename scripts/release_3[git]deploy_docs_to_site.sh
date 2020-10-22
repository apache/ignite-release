#!/usr/bin/env bash

chmod +x release.properties
. ./release.properties

echo "Releasing ${ignite_version}${rc_name}"

rm -r fabric

unzip svn/vote/apache-ignite-${ignite_version}-bin.zip -d fabric

echo "Cloning ignite-website ..."

git clone -b master https://gitbox.apache.org/repos/asf/ignite-website.git

echo "Copying documentation ..."

mkdir ignite-website/releases/$ignite_version
cp -r fabric/apache-ignite-$ignite_version-bin/docs/* ignite-website/releases/$ignite_version
mkdir ignite-website/releases/$ignite_version/cppdoc
cp -r fabric/apache-ignite-$ignite_version-bin/platforms/cpp/docs/* ignite-website/releases/$ignite_version/cppdoc
mkdir ignite-website/releases/$ignite_version/dotnetdoc
cp -r fabric/apache-ignite-$ignite_version-bin/platforms/dotnet/docs/* ignite-website/releases/$ignite_version/dotnetdoc

echo "Commiting changes ..."

cd ignite-website
git add releases/$ignite_version
git commit -m "Ignite $ignite_version docs"

echo "Pushing changes ..."

git push

echo " "
echo "======================================================"
echo "Documentation should be uploaded to site repository"
echo "Please check results at"
echo "https://gitbox.apache.org/repos/asf?p=ignite-website.git"
