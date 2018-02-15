#!/usr/bin/env bash

chmod +x release.properties
. ./release.properties

echo "Preparing vote ${ignite_version}${rc_name}"

server_url="https://repository.apache.org/service/local/staging/deploy/maven2"
server_id="apache.releases.https"

now=$(date +'%H%M%S')

logname="../vote_2_${now}.log"

cd maven

list=$(find ./org -type d -name "ignite-*")

total_cnt=$(find ./org -type d -name "ignite-*" | wc -l)

cnt=0

for dir in $list
do
    main_file=$(find $dir -name "*${ignite_version}.jar")

    pom=$(find $dir -name "*.pom")

    javadoc=$(find $dir -name "*javadoc.jar")

    sources=$(find $dir -name "*sources.jar")

    tests=$(find $dir -name "*tests.jar")

    features=$(find $dir -name "*features.xml")

    adds=""

    cnt=$((cnt+1))

    echo "Uploading ${dir} (${cnt} of ${total_cnt})."

    if [[ $javadoc == *javadoc* ]]
    then
        adds="${adds} -Djavadoc=${javadoc}"
    fi

    if [[ $sources == *sources* ]]
    then
        adds="${adds} -Dsources=${sources}"
    fi

    if [[ $tests == *tests* ]]
    then
        adds="${adds} -Dfiles=${tests} -Dtypes=jar -Dclassifiers=tests"
    fi

    if [[ $features == *features* ]]
    then
        main_file=$pom adds="${adds} -Dpackaging=pom -Dfiles=${features} -Dtypes=xml -Dclassifiers=features"
    fi

    if [[ ! -n $main_file && ! -n $features ]]
    then
        main_file=$pom
        adds="-Dpackaging=pom"
    fi

    echo "Directory:" >> ./$logname
    echo $dir >> ./$logname
    echo "File:" >> ./$logname
    echo $main_file >> ./$logname
    echo "Adds:" >> ./$logname
    echo $adds >> ./$logname
    echo "Features:" >> ./$logname
    echo $features >> ./$logname

    mvn gpg:sign-and-deploy-file -Pgpg -Dfile=$main_file -Durl=$server_url -DrepositoryId=$server_id -DretryFailedDeploymentCount=10 -DpomFile=$pom ${adds} >> ./$logname
done

result="Uploaded"

while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ $line == *ERROR* ]]
    then
        result="Uploading failed. Please check log file: ${logname}."
    fi
done < ./$logname

echo $result

echo " "
echo "======================================================"
echo "Maven staging should be created"
echo "Please check results at"
echo "https://repository.apache.org/#stagingRepositories"
echo "Don't forget to close staging with proper comment"