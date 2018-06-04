#!/bin/bash

NAME="price-checker.sh"
INFO="INFO ($NAME):"
ERROR="ERROR ($NAME):"

function Help {
   echo ""
   echo "$NAME"
   echo ""
   echo " Options:"
   echo "   -m <mail>       - mail address"
   echo ""
}

function SendMail() {
   message="$1"
   mail -s "$NAME" "$mail" <<< "$message"
   echo "$INFO Mail is sent with this message: $message"
}

mail=""
while getopts ":m:" opt; do
   case $opt in
      m)
         mail="$OPTARG"
         ;;
      *)
         Help
         exit 1
         ;;
   esac
done

if [ "x$mail" == "x" ]; then
   echo "$ERROR A mail address must be provided"
   exit 1
fi

curl https://www.xxl.no/helly-hansen-packable-pant-skallbukse-herre/p/1070447_1_style > /tmp/xxl.txt

price=$(grep -oP "<span class=\"price\">\K([0-9]+)" /tmp/xxl.txt)

message=""
if [ "$price" != 899 ]; then
   SendMail "$INFO Price has changed, new price=$price"
fi

