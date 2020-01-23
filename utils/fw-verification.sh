#!/bin/bash

# Script to verify firewall openings

NAME="$(basename $BASH_SOURCE)"
INFO="INFO ($NAME):"
ERROR="ERROR ($NAME):"

HOSTNAME=$(hostname)
TIMEOUT=10

function Help {
   echo ""
   echo "$NAME"
   echo ""
   echo " Options:"
   echo "   -i <inputFile>    - input file containing hosts and ports to verify"
   echo ""
}

inputFile=""
while getopts ":i:" opt; do
   case $opt in
      i)
         inputFile="$OPTARG"
         ;;
      *)
         Help
         exit 1
         ;;
   esac
done

echo "$INFO Running script on $HOSTNAME"

# Check: Must provide an input file
if [[ "x$inputFile" == "x" ]]; then
   echo "$ERROR An input file must be provided"
   exit 1
fi

# Check: If input file exists
if [[ ! -f "$inputFile" ]]; then
   echo "$ERROR Input file: $inputFile, does not exist"
   exit 1
fi

numTests=0
numOkTests=0
numFailedTests=0
# Read input file and verify connection
while IFS= read -r line 
do
   # Skip lines starting with # and empty lines
   if [[ ! "${line:0:1}" == "#" ]] && [[ "$line" != "" ]]; then
      timestamp=$(date "+%Y-%m-%d %H:%M:%S")
      echo "$INFO Verifying ($timestamp): $HOSTNAME -> $line"
      # Run test command
      res=$(echo quit | timeout --signal=9 $TIMEOUT telnet $line 2>&1)
      numTests=$((numTests + 1))
      echo "$res"
      connected="*Connected to*"
      refused="*Connection refused*"
      if [[ "$res" == $connected ]] || [[ "$res" == $refused ]]; then
         echo "$INFO OK"
         numOkTests=$((numOkTests + 1))
      else
         echo "$ERROR Failed"
         numFailedTests=$((numFailedTests + 1))
      fi
      echo ""



      # netcat working example, but nc was not installed on servers when created this script...

      ## Run test command
      #res=$(nc -w $TIMEOUT -z $line 2>&1)
      #numTests=$((numTests + 1))
      #echo "$res"
      #if [[ "$res" == *succeeded* ]]; then
      #   echo "$INFO OK"
      #   numOkTests=$((numOkTests + 1))
      #else
      #   echo "$ERROR Failed"
      #   numFailedTests=$((numFailedTests + 1))
      #fi
   fi
done < $inputFile

echo "$INFO Number of tests:        $numTests"
echo "$INFO Number of ok tests:     $numOkTests"
echo "$INFO Number of failed tests: $numFailedTests"

