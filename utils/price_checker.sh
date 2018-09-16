#!/bin/bash

# Typically run from cron, e.g. every day at 10.00
# 0 10 * * * ~/misc/utils/prize_checker.sh -m me@mail.com
#
# Need to install mailutils
# sudo apt-get install mailuils
# 
# To configure mail (postfix) run: 
# sudo dpkg-reconfigure -plow postfix
# Choose 'Internet site' and defaults

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

#curl https://www.xxl.no/helly-hansen-packable-pant-skallbukse-herre/p/1070447_1_style > /tmp/xxl.txt
curl https://www.xxl.no/micro-micro-black-sparkesykkel-svart/p/1049649_1_style > /tmp/xxl.txt

#price=$(grep -oP "<span class=\"price\">\K([0-9]+)" /tmp/xxl.txt)
price=$(grep -oP "price = \K([0-9]+)" /tmp/xxl.txt)
echo $price

message=""
if [ "$price" != 1799 ]; then
   message="$INFO Price has changed, new price=$price"
else
   message="$INFO Price has not changed, it is still $price"
fi

SendMail "$message"
