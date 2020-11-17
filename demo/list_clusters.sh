#!/bin/bash

BASEDIR=$(dirname $0)
. ${BASEDIR}/config

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} -n cluster-name 
Create a serverless opengauss cluster.
      -h, --help		display help and exit
      -n, --name		set name of opengauss cluster
EOF
}

getopt --test > /dev/null
if [[ $? -ne 4 ]]
then
  echo "Error:`getopt --test` failed in this environment."
  exit 1
fi

# Options of this tool
SHORT=n:h
LONG=name:,help

# Use getopt tool to parse options from users
PARSED=$(getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@")
if [[ $? -ne 0 ]]
then
  show_help
  exit 2
fi

eval set -- "$PARSED"

while true; do
  case "$1" in
    -h|--help)
      shift
      ;;
    -n|--name)
      name="$2"
      shift 2
      ;;
    --)       # End of all options
      shift
      break
      ;;
    *)
      exit 3
      ;;
  esac
done

if [[ -z "$name" ]]; then
    names=($(docker run -it --network serverless_network --rm mysql mysql -h $DB_SERVER_NAME -uroot -p$DB_PWD -D serverless_db -e "select cluster_id,cluster_name from metadata;" | grep -E "[0-9]+" | awk '{print $4}'))
    for n in ${names[@]}; do
        echo ====opengauss cluster "$n":
        docker ps | grep "$n"_
    done
else
    echo ====opengauss cluster "$name":
    docker ps | grep "$name"_
fi


