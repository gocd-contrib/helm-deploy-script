#!/bin/bash

usage() {
    echo "Usage: $0 -f <file_name> | -u <url> [-n <chart_name> -s <namespace>]" 1>&2;
    exit 1;
}

if [ $? != 0 ] ; then usage ; fi

while getopts "n:f:u:s:h" o; do
    case "${o}" in
        n)  CHART_NAME=${OPTARG}
            CHART_NAME_ARGUMENT=${CHART_NAME+"--name $CHART_NAME"}
            ;;
        f)
            FILE_NAME=${OPTARG}
            ;;
        u)
            URL=${OPTARG}
            regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
            if [[ ! $URL =~ $regex ]]; then echo "Invalid URL: $URL"; fi
            exit 1
            ;;
        s)  NAMESPACE=${OPTARG}
            NAMESPACE_ARGUMENT=${NAMESPACE+"--namespace $NAMESPACE"}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z $FILE_NAME ] && [ -z $URL ]; then
    usage
fi
if ! [ -z $FILE_NAME ] && ! [ -z $URL ]; then
    echo "Can't set both Helm chart file name and url arguments "
    usage
fi

CHECK_STATUS_COMMAND="helm ls -q $CHART_NAME"
eval content=\$\($CHECK_STATUS_COMMAND\)

if [ ! -z $content ]; then
    echo "Upgrading existing chart."
    COMMAND="helm upgrade $CHART_NAME $FILE_NAME $URL > status_info.txt"
else
    echo "Installing a new chart."
    COMMAND="helm install $FILE_NAME $URL $CHART_NAME_ARGUMENT $NAMESPACE_ARGUMENT > status_info.txt"
fi

eval $COMMAND