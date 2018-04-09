#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail
set -o errtrace
set -o functrace


now=$(date +'%H%M%S')
logname="vote_3_${now}.log"


#
# Sign artifacts
#
echo "# Starting GPG Agent #"
gpg-connect-agent /bye

list=$(find ./svn/vote -type f -name "*.zip")

for file in $list
do
    echo "Signing ${file}"
	echo ${file} >> ./${logname}
    GPG_AGENT_INFO=~/.gnupg/S.gpg-agent:0:1 gpg -ab ${file} >> ./${logname}
done

result="Signed OK."

while IFS='' read -r line || [[ -n "${line}" ]]; do
    if [[ $line == *ERROR* ]]
    then
        result="Signing failed. Please check log file: ${logname}."
    fi
done < ./${logname}

echo ${result}


#
# Output result and notes
#
echo " "
echo "==============================================="
echo "Artifacts should be signed"
echo "Please check results at ./svn/vote"
echo "Each file should have corresponding *.asc file"
echo
echo "NOTE: Package files are not signed because they"
echo "are meant to be stored in Bintray"
