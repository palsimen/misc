#!/bin/bash

# Checks if a process is running and applies an action if not.

NAME="check_process_and_action.sh"
INFO="INFO ($NAME): "
ERROR="ERROR ($NAME): "

function help {
   echo ""
   echo "$NAME - checks if process is running and applies an action if not"
   echo ""
   echo "   -p - process to search for"
   echo "   -a - action to be executed if process if not running"
   echo ""
}

process_name=""
action=""
while getopts ":p:a:" opt; do
  case $opt in
    p)
      process_name="$OPTARG"
      ;;
    a)
      action="$OPTARG"
      ;;
    *)
      help
      ;;
  esac
done

if [ "x$process_name" == "x" ]; then
   echo "$ERROR Need to provide a process name"
   help
   exit 1
fi
if [ "x$action" == "x" ]; then
   echo "$ERROR Need to provide an action"
   help
   exit 1
fi

# Find pid of process_name
pid=$(~/misc/bin/find_pid $process_name)

# If pid returned is the pid of this process ($$), set it to 0
this_pid="$$"
if [ "$pid" == "$this_pid" ]; then
   pid="0"
fi

if [ "$pid" != "0" ]; then
   echo "$INFO Process $process_name is running with pid=$pid"
else
   echo "$INFO Process $process_name is not running"
   echo "$INFO Running action: $action"
   $action
fi
