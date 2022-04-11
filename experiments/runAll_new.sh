#!/usr/bin/env bash

# NOTE: Use repository https://github.com/ChopinLi-cp/iDFlakies and branch idflakies4iFixPlus
# NOTE: Use repository https://github.com/ChopinLi-cp/testrunner and branch testrunner4iFixPlus
# NOTE: Use repository https://github.com/ChopinLi-cp/xstream and branch borrowState

echo "Enter debugging phase."

if [[ $1 == "" ]]; then
    echo "arg1 - full path to the victim csv file (eg. data/victim.csv)"
    exit
fi

currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "$currentDir"

chmod +x $currentDir/run_debugging_tools_new.sh

function setup() {
    mkdir -p repos/ # Stored in directory repos/
    (
        cd repos/

        mkdir -p testrunner4iFixPlus/
        (
            cd testrunner4iFixPlus/
            # Get right branch of testrunner
            if [[ ! -d testrunner ]]; then
                git clone https://github.com/lcpChopin/testrunner
                (
                    cd testrunner/
                    git checkout -f testrunner4iFixPlus
                    mvn clean install -DskipTests
                )
            fi
        )

        mkdir -p iFixFlakies4iFixPlus/
        (
            cd iFixFlakies4iFixPlus/
            # Get current version of iFixFlakies
            if [[ ! -d iFixFlakies ]]; then
                git clone https://github.com/lcpChopin/iFixFlakies.git
                (
                    cd iFixFlakies
                    git checkout -f iFixFlakies4iFixPlus
                    mvn clean install -DskipTests
                )
            fi
        )

        mkdir -p borrowState/
        (
            cd borrowState/
            # Get current version of xstream
            if [[ ! -d xstream ]]; then
                git clone https://github.com/ChopinLi-cp/xstream
                (
                    cd xstream/
                    git checkout -f borrowState
                    mvn clean install -DskipTests
                )
            fi
        )
    )

    (
        cd reseter-finder/
        mvn clean install -DskipTests
    )
}

# setup
createrootfolder_script=$currentDir"/createrootfolders.sh"
bash $createrootfolder_script

input=$1
inputProjRoot=$currentDir"/projectsInstall/projects"
echo "$input"
while IFS= read -r line
do
  slug=$(echo $line | cut -d',' -f1)
  sha=$(echo $line | cut -d',' -f2)
  module=$(echo $line | cut -d',' -f3)
  odtest=$(echo $line | cut -d',' -f4)

  if [[ ${line} = "\#*" ]]; then continue; fi
  #echo "**************************slug: $slug"
  #echo "odtest: $odtest"
  if [[ ! -d ${inputProjRoot}/${slug} ]]; then
    git clone "https://github.com/$slug" $inputProjRoot/$slug
    (
        cd $inputProjRoot/$slug
        git checkout $sha
    )
    MVNOPTIONS="-DskipTests -Ddependency-check.skip=true -Denforcer.skip=true -Drat.skip=true -Dmdep.analyze.skip=true -Dmaven.javadoc.skip=true -Dgpg.skip -Dlicense.skip=true  -Dskip=true"
    if [[ $module == "." ]]; then
      PL=""
    else
      PL="-pl $module -am"
    fi
    echo "module: $module"
    (
        cd $inputProjRoot/$slug
        mvn clean install ${PL} ${MVNOPTIONS}
    )
    pom_modify_script=$currentDir/pom-modify-ifixplus/modify-project.sh
    $pom_modify_script $inputProjRoot/$slug
  fi
  $currentDir/run_debugging_tools_new.sh $slug $sha $odtest $module
  mkdir -p _downloads
done < "$input"
