#!/usr/bin/env bash

echo "*******************IFIXPLUS************************"
echo "Starting run_debugging_tools.sh"

git rev-parse HEAD
date

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]]; then
    echo "arg1 - GitHub SLUG"
    echo "arg2 - sha"
    echo "arg3 - Test name"
    echo "arg4 - module name"
    exit
fi

slug=$1
sha=$2
testName=$3
moduleName0=$4

rootScriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo "rootScriptDir: $rootScriptDir"
download_json_script=$rootScriptDir"/download-minimizer-results.sh"
createfolder_script=$rootScriptDir"/createfolders.sh"
createrootfolder_script=$rootScriptDir"/createrootfolders.sh"
pkg_filter_script=$rootScriptDir"/package_finder.py"
module_script=$rootScriptDir"/get_module_name.py"
outputResult_script=$rootScriptDir"/outputResults.sh"
echo "pkg_filter_script: $pkg_filter_script"

# create the root folders
bash $createrootfolder_script

# create the sub folders for the specific slug
bash $createfolder_script $slug $testName "xmls"
#bash $createfolder_script $slug $testName "dtjsons"
bash $createfolder_script $slug $testName "roots"
bash $createfolder_script $slug $testName "diffs"
bash $createfolder_script $slug $testName "pkg"
bash $createfolder_script $slug $testName "subxmls"
bash $createfolder_script $slug $testName "reflection"
bash $createfolder_script $slug $testName "logs"
bash $createfolder_script $slug $testName "module"
bash $createfolder_script $slug $testName "allFields"
bash $createfolder_script $slug $testName "diffFields"
bash $createfolder_script $slug $testName "subdiffs"

jsonFold=$rootScriptDir"/jsonFiles_0/"$testName 
echo "json folder: $jsonFold"
xmlFold=$rootScriptDir"/xmls/"$slug"/"$testName 
echo "xml folder: $xmlFold"
rootFile=$rootScriptDir"/roots/"$slug"/"$testName"/failing_order.txt" 
diffFold=$rootScriptDir"/diffs/"$slug"/"$testName 
pkgFold=$rootScriptDir"/pkg/"$slug"/"$testName
xmlDir=$rootScriptDir"/subxmls/"$slug"/"$testName
reflectionFile=$rootScriptDir"/reflection/"$slug"/"$testName"/reflection.txt"
output=$rootScriptDir"/output/result.csv"
logFold=$rootScriptDir"/logs/"$slug"/"$testName
logFile=$logFold"/log"
moduleFold=$rootScriptDir"/module/"$slug"/"$testName
moduleFile=$moduleFold"/module"
allFieldsFile=$rootScriptDir"/allFields/"$slug"/"$testName"/failing_order.txt"
diffFieldsFile=$rootScriptDir"/diffFields/"$slug"/"$testName"/diffFields.txt"
eagerLoadFile=$rootScriptDir"/roots/"$slug"/"$testName"/eagerLoadFile.txt"
subdiffsFold=$rootScriptDir"/subdiffs/"$slug"/"$testName 
interleave=true

# this json has just the polluter for the failing order
json=$jsonFold"/flaky-lists.json"
#cd $jsonFold"/minimized/"
json2=""
#echo "json2: $json2"

# dir of the input project which is downloaded and whose pom.xml has been modified
#rootDir=${rootScriptDir%/*}
rootDir=${rootScriptDir}
# echo "ROOTDIR:",$rootDir
inputProjDir=$rootDir"/projectsInstall/projects/"$slug
# echo "INPUTPROJDIR:",$inputProjDir

# generate the package-filter file
# Used as whitelist to restrict capturing only classes in these packages, but not used right now
pkgFile=$pkgFold"/package-filter"
python $pkg_filter_script $inputProjDir > $pkgFile
echo "generated package-filter file $pkgFile"

if [[ ${moduleName0} == "." ]]; then
  moduleName=${inputProjDir}
else
  moduleName=${inputProjDir}/${moduleName0}
fi

# go to the input project directory
cd $moduleName
echo "moduleName: $moduleName"

# print header to the result file
printf '%s' "$slug,$sha,$moduleName0,$testName," >> $output

tmpfile=$rootScriptDir"/tmp"
# execute iFixPlus
MVNOPTIONS="-Ddependency-check.skip=true -Denforcer.skip=true -Drat.skip=true -Dmdep.analyze.skip=true -Dmaven.javadoc.skip=true -Dgpg.skip -Dlicense.skip=true"
TESTRUNNERVERSION="1.3-SNAPSHOT"

mvn testrunner:testplugin ${MVNOPTIONS} -Ddetector.detector_type=random-class-method -Ddt.detector.original_order.all_must_pass=false -Dtestplugin.runner.capture_state=true -Dtestplugin.javaagent="${HOME}/.m2/repository/edu/illinois/cs/testrunner-running/${TESTRUNNERVERSION}/testrunner-running-${TESTRUNNERVERSION}.jar=" -Dtestplugin.className=edu.illinois.cs.dt.tools.utility.iFixPlusPlugin -Dreplay.path=$json -Dreplay.path2=$json2 -Dstatecapture.testname=$testName -Dstatecapture.xmlDir=$xmlDir -Dstatecapture.rootFile=$rootFile -Dreplay.pkgFile=$pkgFile -Dreplay.diffFold=$diffFold -Dreplay.slug=$slug -Dreplay.output=$output -Dreplay.module=$moduleName -Dstatecapture.allFieldsFile=$allFieldsFile -Dreplay.diffFieldsFile=$diffFieldsFile -Dreplay.subdiffsFold=$subdiffsFold -Dreplay.tmpfile=$tmpfile -Dstatecapture.reflectionFile=$reflectionFile -Dstatecapture.eagerloadfile=$eagerLoadFile -Dtestrunner.interleave=$interleave > $logFile 2>&1

echo $rootFile $allFieldsFile $diffFieldsFile
# output results
bash $outputResult_script $rootFile $allFieldsFile $diffFieldsFile >> $output


echo "*******************IFIXPLUS************************"
echo "Finished run_debugging_tools.sh"
date

