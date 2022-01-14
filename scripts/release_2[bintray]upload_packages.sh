#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
set -o errtrace

set -o functrace

###
### Ignite deb
###
#
# To deploy a Debian package into Artifactory you can either use the deploy option in the Artifact’s module or
# upload with cURL using matrix parameters. The required parameters are package name, distribution, component,
# and architecture in the following way:
#
# curl -H "X-JFrog-Art-Api:<API_KEY>" -XPUT "https://apache.jfrog.io/artifactory/ignite-deb/pool/<DEBIAN_PACKAGE_NAME>;
# deb.distribution=<DISTRIBUTION>;deb.component=<COMPONENT>;deb.architecture=<ARCHITECTURE>" -T <PATH_TO_FILE>
#
# You can specify multiple layouts by adding semicolon separated multiple parameters, like so:
#
# curl -H "X-JFrog-Art-Api:<API_KEY>" -XPUT "https://apache.jfrog.io/artifactory/ignite-deb/pool/<DEBIAN_PACKAGE_NAME>;
# deb.distribution=<DISTRIBUTION>;deb.distribution=<DISTRIBUTION>;deb.component=<COMPONENT>;deb.component=<COMPONENT>;
# deb.architecture=<ARCHITECTURE>;deb.architecture=<ARCHITECTURE>" -T <PATH_TO_FILE>
#
# To add an architecture independent layout use deb.architecture=all. This will cause your package to appear in the
# Packages index of all the architectures under the same Distribution and Component, as well as under a new index
# branch called binary-all which holds all Debian packages that are marked as "all".
#
###
### Ignite rpm
###
#
# To deploy an RPM package into an Artifactory repository you need to use Artifactory's REST API or Web UI.
# For example, to deploy an RPM package into this repository using the REST API, use the following command:
#
# curl -H "X-JFrog-Art-Api:<API_KEY>" -XPUT https://apache.jfrog.io/artifactory/ignite-rpm/<PATH_TO_METADATA_ROOT> -T <TARGET_FILE_PATH>
#
# The PATH_TO_METADATA_ROOT is according to the repository configured metadata folder depth.

chmod +x release.properties
. ./release.properties

# Curl authentication string for accessing Bintray
AUTH=""

#
# Function: Check whether target package at Apache JFrog artifactory already exists and create new package definition by template if it does not
#
checkPackageExistence () {
    repository="$1"
    package_name="$2"
    description="$3"

    check_message="$(curl -H "X-JFrog-Art-Api:${AUTH}" -X GET https://apache.jfrog.io/artifactory/"${repository}"/"${package_name}" 2>/dev/null)"
    if [ "${check_message}" == "{\"message\":\"Package '${package_name}' was not found\"}" ]; then
        echo -n "Package '${package_name}' does not exist, creating... "
        curl -H "X-JFrog-Art-Api:${AUTH}" \
             -H "Content-Type: application/json" \
                     -X POST "https://apache.jfrog.io/artifactory/${repository}" \
                     -d "{\"name\": \"${package_name}\",\"desc\": \"${description}\",\"labels\": [],\"licenses\": [\"Apache-2.0\"],\"custom_licenses\": [],\"vcs_url\": \"https://github.com/apache/ignite.git\",\"website_url\": \"https://ignite.apache.org\",\"issue_tracker_url\": \"https://issues/apache.org/jira/browse/IGNITE\",\"github_repo\": \"apache/ignite\",\"github_release_notes_file\": \"RELEASE_NOTES.txt\",\"public_download_numbers\": false,\"public_stats\": false}" 2>/dev/null | grep -q "\"name\":\"${package_name}\"" || { echo "ERROR"; exit 1; }
        echo "Done"
    else
        echo "       Package '${package_name}' already exists, skipping package creation"
    fi
}

#
# Get credentials for accessing Bintray RPM repository
#

response=""
echo "You can find the API key at the 'Authentication Settings' on https://apache.jfrog.io/ using your PMC credentials."
echo "Paste API key for accessing Apache JFrog artifactory:"
read -rs key

AUTH="${key}"

response=$(curl -H "X-JFrog-Art-Api:${AUTH}" -X GET https://apache.jfrog.io/artifactory/api/search/artifact?name=apache-ignite 2>/dev/null)
error=$(echo "${response}" | jq -r '(try .errors[].message catch 0)')

[[ "$error" != "0" ]] && { echo -e "Error accessing JFrog artifactory using token: \n$error"; exit 1; }

echo "Successfully authenticated at Apache JFrog."
echo

#
# Release RPM packages:
#  * upload to Bintray
#  * publish
#

echo "1. Moving RPM packages to Apache JFrog artifactory"
OLDPWD=$(pwd)
cd packages/pkg
for rpm in *.rpm; do
    package_name=$(echo "${rpm}" | \
                       sed -r "s|(.*)-${ignite_version}.*|\1|")    # Get RPM package name
    description=$(grep -Pzo "(?s)\N*%description.*?%" ../rpm/apache-ignite.spec | \
                    tail -n +2 | \
                    head -n -1 | \
                    grep -v "^$" | \
                    sed -r ':a;N;$!ba;s/\n/\ /g')                # Get RPM package description
    repository="ignite-rpm"

    checkPackageExistence "${repository}" "${package_name}" "${description}"
    response=$(curl -H "X-JFrog-Art-Api:${AUTH}" -X PUT https://apache.jfrog.io/artifactory/ignite-rpm/"${package_name}"/"${ignite_version}"/"${rpm}" -T "${rpm}")

    echo "$response"
done
echo
cd "${OLDPWD}"


#
# Release DEB packages:
#  * upload to Bintray
#  * publish
#
echo "2. Moving DEB packages to Apache JFrog artifactory"
cd packages/pkg
for deb in *.deb; do
    package_name=$(echo "${deb}" |\
                       cut -f1 -d_)                    # Get DEB package name
    description=$(grep -Pzo "(?s)\N*Description.*?Homepage" ../deb/control | \
                    tail -n +2 | \
                    head -n -1 | \
                    sed -r 's|^\s+||' | \
                    sed -r ':a;N;$!ba;s/\n/\ /g')    # Get DEB package description
    repository="ignite-deb"
    component="main"

    checkPackageExistence "${repository}" "${package_name}" "${description}"
    response=$(curl -H "X-JFrog-Art-Api:${AUTH}" -X PUT "https://apache.jfrog.io/artifactory/ignite-deb/pool/$component/apache-ignite/$ignite_version/$deb;deb.distribution=apache-ignite;deb.component=$component;deb.architecture=all;overrideExistingFiles=true" -T "${deb}")
done

#
# Remove packages from DEV
#
echo "3. Removing packages from Apache Ignites DEV site"
svn del https://dist.apache.org/repos/dist/dev/ignite/packages_"${ignite_version}""${rc_name}" -m "Release ${ignite_version}: Removed moved to Bintray packages"
echo

#
# Output result and notes
#
echo "============================================"
echo "Packages should be moved to Apache JFrog artifactory"
echo "Please check results at:"
echo " * rpms: https://apache.org/dist/ignite/rpm/"
echo " * debs: https://apache.org/dist/ignite/deb/"

