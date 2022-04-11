#!/usr/bin/env bash

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]]; then
    echo "arg1 - rootFile"
    echo "arg2 - allFieldsFile"
    echo "arg3 - diffFieldsFile"
    exit
fi

# rootFold=$1
# allFieldsFold=$2
# diffFieldsFold=$3

root1=$1 # $rootFold"/failing_order.txt"
field1=$2 # $allFieldsFold"/failing_order.txt"
diffF=$3 # $diffFieldsFold"/diffFields.txt"

getnum(){
  local arg1=$1
  if [ -f "$arg1" ]; then
    local num=$(grep "" -c $arg1)
    echo "$num"
  else 
    local num="null"
    echo "null"
  fi
}


root1num=$(getnum $root1)
field1num=$(getnum $field1)
diffFnum=$(getnum $diffF)

result=$field1num","$root1num","$diffFnum
echo "$result"

