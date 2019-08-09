#!/bin/bash

NAME="$(basename $BASH_SOURCE)"
INFO="INFO ($NAME):"
ERROR="ERROR ($NAME):"

DIFF_DIR="$PWD/diffs"

function Help {
   echo ""
   echo "$NAME"
   echo ""
   echo " Options:"
   echo "   -r <Repository> - repository to diff"
   echo "   -f <From>       - from tag"
   echo "   -t <To>         - to tag"
   echo ""
}

repo=""
from=""
to=""
while getopts ":r:f:t:" opt; do
   case $opt in
      r)
         repo="$OPTARG"
         ;;
      f)
         from="$OPTARG"
         ;;
      t)
         to="$OPTARG"
         ;;
      *)
         Help
         exit 1
         ;;
   esac
done

if [ "x$repo" == "x" ]; then
   echo "$ERROR A repository must be provided"
   exit 1
fi
if [ "x$from" == "x" ]; then
   echo "$ERROR A from tag must be provided"
   exit 1
fi
if [ "x$to" == "x" ]; then
   echo "$ERROR A to tag must be provided"
   exit 1
fi

filename="${repo}_patch_${from}_${to}.diff"
diffString="version_${from}..version_${to}"

cd $repo
mkdir -p $DIFF_DIR
git fetch --all
git fetch --tags
git diff --no-prefix $diffString > $DIFF_DIR/$filename
cd - > /dev/null

echo "$INFO Done"
