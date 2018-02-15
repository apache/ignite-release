#!/usr/bin/env bash

now=$(date +'%H%M%S')
logname="vote_3_${now}.log"

echo "# Starting GPG Agent #"
gpg-connect-agent /bye

list=$({ find ./svn/vote -type f -name "*.zip"; find ./rpm -type f -name "*"; })

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

echo " "
echo "=============================================="
echo "Artifacts should be signed"
echo "Please check results at ./svn/vote and ./rpm"
echo "Each file should have corresponding *.asc file"

