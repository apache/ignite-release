#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
set -o errtrace
set -o functrace


chmod +x release.properties
. ./release.properties


AUTH=""    # Curl authentication string for accessing Bintray


#
# Function: Check whether target package at Bintray already exists and create new package definition by template if it does not
#
checkPackageExistance () {
    repository="$1"
    package_name="$2"
    description="$3"

    check_message="$(curl ${AUTH} -X GET https://api.bintray.com/packages/apache/${repository}/${package_name} 2>/dev/null)"
    if [ "${check_message}" == "{\"message\":\"Package '${package_name}' was not found\"}" ]; then
        echo -n "       Package '${package_name}' does not exist, creating... "
        curl ${AUTH} \
             -H "Content-Type: application/json" \
                     -X POST "https://api.bintray.com/packages/apache/${repository}" \
                     -d "{\"name\": \"${package_name}\",\"desc\": \"${description}\",\"labels\": [],\"licenses\": [\"Apache-2.0\"],\"custom_licenses\": [],\"vcs_url\": \"https://github.com/apache/ignite.git\",\"website_url\": \"https://ignite.apache.org\",\"issue_tracker_url\": \"https://issues/apache.org/jira/browse/IGNITE\",\"github_repo\": \"apache/ignite\",\"github_release_notes_file\": \"RELEASE_NOTES.txt\",\"public_download_numbers\": false,\"public_stats\": false}" 2>/dev/null | grep -q "\"name\":\"${package_name}\"" || { echo "ERROR"; exit 1; }
        echo "Done"
    else
        echo "       Package '${package_name}' already exists, skipping package creation"
    fi
}


#
# Function: Upload target package to Bintary (version will be created automatically)
#
upload () {
    repository="${1}"
    package_name="${2}"
    file="${3}"
    path="${4:-}"
    properties="${5:-};publish=1;override=1"

    echo -n "       Uploading '${file}' to Bintray... "
    curl -T ${file} ${AUTH} "https://api.bintray.com/content/apache/${repository}/${package_name}/${ignite_version}/${path}${file}${properties}" 2>/dev/null | grep -q '{"warn":"The target repository is configured to auto-sign, but the private key requires a passphrase and none was provided. No files will be signed"}' || { echo "ERROR"; exit 1; }
    echo "Done"
}


echo "# Releasing ${ignite_version}${rc_name} :: Packages #"


#
# Get credentials for accessing Bintray RPM repository
#
i=1
response=""
while [ $i -le 3 -a "${response}" != "{\"message\":\"forbidden\"}" ]; do
    echo "Please, enter credentials for accessing Bintray RPM repository"
    read -p    "    Username: " user
    read -s -p "    API key: "  key
    AUTH="-u${user}:${key}"
    response=$(curl ${AUTH} -X POST "https://api.bintray.com/usage/apache" 2>/dev/null)
    i=$((i+1))
    echo
done
if [ $i -gt 3 -a "${response}" != "{\"message\":\"forbidden\"}" ]; then
    echo "[ERROR] Failed to get valid credentials for Bintray RPM repository"
    exit 1
else
    echo "Successfully authenticated at Bintray"
    echo
fi


#
# Release RPM packages:
#  * upload to Bintray
#  * publish
#
echo "1. Moving RPM packages to Bintray"
cd packaging/pkg
for rpm in *.rpm; do
    package_name=$(echo ${rpm} | \
                       sed -r "s|(.*)-${ignite_version}.*|\1|")    # Get RPM package name
    description=$(cat ../rpm/apache-ignite.spec | \
                      grep -Pzo "(?s)\N*%description.*?%" | \
                      tail -n +2 | \
                      head -n -1 | \
                      grep -v "^$" | \
                      sed -r ':a;N;$!ba;s/\n/\ /g')                # Get RPM package description
    repository="ignite-rpm"

    echo "   ${rpm}"

    checkPackageExistance "${repository}" "${package_name}" "${description}"
    upload "${repository}" "${package_name}" "${rpm}"
done
echo
cd ${OLDPWD}


#
# Release DEB packages:
#  * upload to Bintray
#  * publish
#
echo "2. Moving DEB packages to Bintray"
cd packaging/pkg
for deb in *.deb; do
    package_name=$(echo ${deb} |\
                       cut -f1 -d_)                    # Get DEB package name
    description=$(cat ../deb/control | \
                      grep -Pzo "(?s)\N*Description.*?Homepage" | \
                      tail -n +2 | \
                      head -n -1 | \
                      sed -r 's|^\s+||' | \
                      sed -r ':a;N;$!ba;s/\n/\ /g')    # Get DEB package description
    repository="ignite-deb"
    component="main"
    path="pool/${component}/${deb:0:1}/"

    echo "   ${deb}"

    checkPackageExistance "${repository}" "${package_name}" "${description}"
    upload "${repository}" "${package_name}" "${deb}" "${path}" ";deb_distribution=apache-ignite;deb_component=${component};deb_architecture=all"
done


#
# Remove packages from DEV
#
echo "3. Removing packages from Apache Ignite's DEV site"
svn del https://dist.apache.org/repos/dist/dev/ignite/packages_${ignite_version}${rc_name} -m "Release ${ignite_version}: Removed moved to Bintray packages"
echo


#
# Output result and notes
#
echo "============================================"
echo "Packages should be moved to Bintray"
echo "Please check results at:"
echo " * rpms: https://apache.org/dist/ignite/rpm/"
echo " * debs: https://apache.org/dist/ignite/deb/"

