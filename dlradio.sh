#!/bin/bash

WORKFILE=""
RECFILE=""
DURATION="10"
BUFFER="1"

on_exit()
{
    [[ -n ${WORKFILE} ]] && rm -f "${WORKFILE}"
	exit 0
}

err_exit()
{
    echo "Usage: dlradio.sh -u <url> -l <playlist> -w <workfile> -r <recfile> [-d <duration>] [-b <buffer>]"
    [[ -n ${WORKFILE} ]] && rm -f "${WORKFILE}"
    exit 1
}

while getopts u:l:d:w:r:b: OPT
do
    case $OPT in
    "u") URL=${OPTARG} ;;
    "l") PLAYLIST=${OPTARG} ;;
    "d") DURATION=${OPTARG} ;;
    "b") BUFFER=${OPTARG} ;;
    "w") WORKFILE=${OPTARG} ;;
    "r") RECFILE=${OPTARG} ;;
    "\?") err_exit ;;
  esac
done

if [ -z "${WORKFILE}" -o -z "${RECFILE}" ]; then
    err_exit
fi

if [ ${DURATION} -gt 100000 ]; then
    DURATION="100000"
fi

readonly DATETIME=`date '+%m_%d_%H%M'`
timeNow=`date "+%s"`
readonly TIMESTOP=`expr ${timeNow} + ${DURATION}`
readonly URL_PL="${URL%/}/${PLAYLIST}"
fileDownloaded="none"
PREBUFFER=`expr ${BUFFER} \* 2 - 1`
FLIST=`mktemp /tmp/xml.XXXXXXXX`

if [ -z ${URL} -o -z ${PLAYLIST} ]; then
    err_exit
else
    echo "palypath :${URL_PL}"
    echo "duration :${DURATION}"
    echo "buffer   :${PREBUFFER}"
    echo "work file:${WORKFILE}"
    echo "rec file :${RECFILE}"
fi

trap on_exit EXIT
trap on_exit INT PIPE TERM

curl -o "${FLIST}" ${URL_PL} 2>/dev/null
while [ ${PREBUFFER} -gt "0" ]
do
    fileInput=`tail -n ${PREBUFFER} "${FLIST}"|head -n 1|tr -d '\r\n'`
    if [ "${fileInput}" != "${fileDownloaded}" ]; then
        filePath="${URL%/}/${fileInput}"
        curl -f "${filePath}" -o ${WORKFILE} 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "${PREBUFFER}:${fileInput}"
            cat ${WORKFILE} >>"${RECFILE}"
            fileDownloaded="${fileInput}"
        fi
    fi
    PREBUFFER=`expr ${PREBUFFER} - 2`
done
rm "${FLIST}"

indexFile="0"
while [ ${TIMESTOP} -ge ${timeNow} ]
do
    fileInput=`curl ${URL_PL} 2>/dev/null|tail -n 1|tr -d '\r\n'`
    if [ "${fileInput}" != "${fileDownloaded}" ]; then
        filePath="${URL%/}/${fileInput}"
        curl -f "${filePath}" -o ${WORKFILE} 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "${indexFile}:${fileInput}"
            cat ${WORKFILE} >>"${RECFILE}"
            fileDownloaded="${fileInput}"
            indexFile=`expr ${indexFile} + 1`
        else
            echo "fail:${fileInput}"
        fi
    fi
    sleep 4
    timeNow=`date "+%s"`
done
rm -f ${WORKFILE}
exit 0
