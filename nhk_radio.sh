#!/bin/bash

readonly CMDNAME=`basename $0`
pushd `dirname $0` >/dev/null 2>&1
readonly DIRNAME=`pwd`
popd >/dev/null 2>&1
FFMPEG=`which ffmpeg`
if [ -z "${FFMPEG}" ]; then
	FFMPEG="${DIRNAME%/}/ffmpeg"
fi

readonly DATETIME=`date '+%m_%d_%H%M'`
readonly DATE=`date '+%m_%d'`
readonly YEAR=`date '+%Y'`
if [ -z "${HOME}" ]; then
	RECPATH="/tmp/radio"
else
	RECPATH="${HOME%/}/radio"
fi
mkdir ${RECPATH} 2>/dev/null
readonly TMPFILE=`mktemp ${RECPATH}/dl.XXXXXX`
readonly RECFILE=`mktemp ${RECPATH}/rec.XXXXXX`
readonly DLLOGFILE="${RECPATH}/dlradio.log"
readonly UNAME=`uname`
STATION="error"
ARG_ST="tokyo"
CHANNEL="fm"
GROUP="NHK FM"
ARTIST="unknown"
PORR="play"
FNPOST="T"
ALBUM="Radio"
TITLE=""
OUTFILE=""
URL=""
DURATION="1"
HELP="0"
DEVNAME="bcm2835 ALSA"
PREBUF="6"
ACARD="0"
ADEVICE="0"

if [ $UNAME != "Darwin" ] && [ $UNAME != "Linux" ]
then
	exit 1
fi

while getopts a:b:c:d:f:t:hmprs: OPT
do
	case $OPT in
	"a") ARTIST=${OPTARG} ;;
	"b") PREBUF=${OPTARG} ;;
	"c") CHANNEL=${OPTARG} ;;
	"d") DEVNAME=${OPTARG} ;;
	"f") ALBUM=${OPTARG} ;;
	"t") TITLE=${OPTARG} ;;
	"h") HELP="1" ;;
	"m") DURATION="60" ;;
	"p") PORR="play" ;;
	"r") PORR="rec" ;;
	"s") ARG_ST=${OPTARG} ;;
  esac
done

if [ $UNAME != "Darwin" ]; then
	ACARD=`aplay -l|grep -m 1 "${DEVNAME}"|sed -E "s/\s+/ /g"|awk -F'[: ]' '{print $2}'`
	ADEVICE=`aplay -l|grep -m 1 "${DEVNAME}"|sed -E "s/${DEVNAME}/QQ/g"|sed -E "s/[: ]+/ /g"|awk '{print $6}'`
fi

case $CHANNEL in
	r1) CHANNEL="r1" ; GROUP="NHK R1" ; PLAYLIST="1-r1-01.m3u8" ;;
	r2) CHANNEL="r2" ; GROUP="NHK R2" ; PLAYLIST="1-r2-01.m3u8" ;;
	fm) CHANNEL="fm" ; GROUP="NHK FM" ; PLAYLIST="1-fm-01.m3u8" ;;
esac

case $ARG_ST in
	"tokyo")	 STATION="tokyo" ;	   FNPOST="T" ;;
	"TOKYO")	 STATION="tokyo" ;	   FNPOST="T" ;;
	"sapporo")	 STATION="sapporo" ;   FNPOST="Sa" ;;
	"SAPPORO")	 STATION="sapporo" ;   FNPOST="Sa" ;;
	"sendai")	 STATION="sendai" ;	   FNPOST="Se" ;;
	"SENDAI")	 STATION="sendai" ;	   FNPOST="Se" ;;
	"nagoya")	 STATION="nagoya" ;	   FNPOST="N" ;;
	"NAGOYA")	 STATION="nagoya" ;	   FNPOST="N" ;;
	"osaka")	 STATION="osaka" ;	   FNPOST="O" ;;
	"OSAKA")	 STATION="osaka" ;	   FNPOST="O" ;;
	"hiroshima") STATION="hiroshima" ; FNPOST="H" ;;
	"HIROSHIMA") STATION="hiroshima" ; FNPOST="H" ;;
	"matsuyama") STATION="matsuyama" ; FNPOST="M" ;;
	"MATSUYAMA") STATION="matsuyama" ; FNPOST="M" ;;
	"fukuoka")	 STATION="fukuoka" ;   FNPOST="F" ;;
	"FUKUOKA")	 STATION="fukuoka" ;   FNPOST="F" ;;
esac

OUTFILE="${ALBUM}_${DATETIME}_AirCheck${FNPOST}"

if [ $STATION = "sapporo" ]; then
	case $CHANNEL in
		r1) URL='http://nhkradioikr1-i.akamaihd.net/hls/live/512098/1-r1/' ;;
		fm) URL='http://nhkradioikfm-i.akamaihd.net/hls/live/512100/1-fm/' ;;
	esac
fi
if [ $STATION = "sendai" ]; then
	case $CHANNEL in
		r1) URL='http://nhkradiohkr1-i.akamaihd.net/hls/live/512075/1-r1/' ;;
		fm) URL='http://nhkradiohkfm-i.akamaihd.net/hls/live/512076/1-fm/' ;;
	esac
fi
if [ $STATION = "tokyo" ]; then
	case $CHANNEL in
		r1) URL='http://nhkradioakr1-i.akamaihd.net/hls/live/511633/1-r1/' ;;
		fm) URL='http://nhkradioakfm-i.akamaihd.net/hls/live/512290/1-fm/' ;;
	esac
fi
if [ $STATION = "nagoya" ]; then
	case $CHANNEL in
		r1) URL='http://nhkradiockr1-i.akamaihd.net/hls/live/512072/1-r1/' ;;
		fm) URL='http://nhkradiockfm-i.akamaihd.net/hls/live/512074/1-fm/' ;;
	esac
fi
if [ $STATION = "osaka" ]; then
	case $CHANNEL in
		r1) URL='http://nhkradiobkr1-i.akamaihd.net/hls/live/512291/1-r1/' ;;
		fm) URL='http://nhkradiobkfm-i.akamaihd.net/hls/live/512070/1-fm/' ;;
	esac
fi
if [ $STATION = "hiroshima" ]; then
	case $CHANNEL in
		r1) URL='http://nhkradiofkr1-i.akamaihd.net/hls/live/512086/1-r1/' ;;
		fm) URL='http://nhkradiofkfm-i.akamaihd.net/hls/live/512087/1-fm/' ;;
	esac
fi
if [ $STATION = "matsuyama" ]; then
	case $CHANNEL in
		r1) URL='http://nhkradiozkr1-i.akamaihd.net/hls/live/512103/1-r1/' ;;
		fm) URL='http://nhkradiozkfm-i.akamaihd.net/hls/live/512106/1-fm/' ;;
	esac
fi
if [ $STATION = "fukuoka" ]; then
	case $CHANNEL in
		r1) URL='http://nhkradiolkr1-i.akamaihd.net/hls/live/512088/1-r1/' ;;
		fm) URL='http://nhkradiolkfm-i.akamaihd.net/hls/live/512097/1-fm/' ;;
	esac
fi
if [ $CHANNEL = "r2" ]; then
		URL='http://nhkradioakr2-i.akamaihd.net/hls/live/511929/1-r2/'
fi

if [ ${OPTIND} -ge 1 ]; then
	shift `expr ${OPTIND} - 1`
fi

if [ $# -ge 1 ] && [ $HELP = "0" ]
then
	DURATION=`expr ${1} \* ${DURATION}`
else
	echo "usage : $0 [options] duration(sec/min)"
	echo "	-a artist  : set artist name (rec)"
	echo "	-b buffer  : set buffer size [10sec] (play, 1=10sec..20=200sec)"
	echo "	-c channel : r1, r2, or fm"
	echo "	-d device  : playback device name (play)"
	echo "	-f album   : set album name (rec)"
	echo "	-t title   : set title name (rec)"
	echo "	-m		   : set duration as minutes (default seconds)"
	echo "	-p		   : play radio (default)"
	echo "	-r		   : record radio"
	echo "	-s station : select station, sapporo, sendai, tokyo(default),"
	echo "				 nagoya, osaka, hiroshima, matsuyama, or fukuoka"
	exit 1
fi

echo "station  = ${STATION}"
echo "channel  = ${CHANNEL}"
echo "url      = ${URL}"
echo "path     = ${PLAYPATH}"
echo "porr     = ${PORR}"
echo "device   = ${DEVNAME}"
echo "buffer   = ${PREBUF}0[s]"
echo "duration = ${DURATION}[s]"
echo "artist   = ${ARTIST}"
echo "album    = ${ALBUM}"
echo "title    = ${TITLE}"
echo "file     = ${OUTFILE}"

if [ $PORR = "rec" ]; then
	DURATION=`expr 10 + ${DURATION}`
	"${DIRNAME%/}/dlradio.sh" -u "${URL}" -l "${PLAYLIST}" -d "${DURATION}" \
		-w "${TMPFILE}" -r "${RECFILE}" >${DLLOGFILE} 2>&1
else
	"${DIRNAME%/}/dlradio.sh" -u "${URL}" -l "${PLAYLIST}" -d "${DURATION}" \
		-w "${TMPFILE}" -r "${RECFILE}" -b "${PREBUF}" >${DLLOGFILE} 2>&1 &
fi
PIDDL=$!
echo "dlradio:${PIDDL}"

timeNow=`date "+%s"`
readonly TIMESTOP=`expr ${timeNow} + ${DURATION}`

on_exit()
{
	kill -KILL "${PIDDL}" >/dev/null 2>&1
    [[ -e ${TMPFILE} ]] && rm -f "${TMPFILE}"
    [[ -e ${RECFILE} ]] && rm -f "${RECFILE}"
	exit 0
}

trap on_exit EXIT
trap 'echo "user exit"; kill $(jobs -p); on_exit' INT PIPE TERM

if [ $PORR = "play" ]; then
	while [ ${TIMESTOP} -ge ${timeNow} ]
	do
		sleep 1
		if [ -s "${RECFILE}" ]; then
			if [ $UNAME = "Darwin" ]; then
				mplayer "${RECFILE}"
			else
				mplayer -ao alsa:noblock:device=hw=${ACARD},${ADEVICE} "${RECFILE}"
			fi
			if [ $? -ne 0 ]; then
				break;
			fi
			rm "${RECFILE}"
		fi
	    timeNow=`date "+%s"`
	done
else
	if [ -n "${FFMPEG}" ]; then
		"${FFMPEG}" -y -i "${RECFILE}" \
			-loglevel warning \
			-acodec copy \
			-bsf:a aac_adtstoasc \
			-metadata title="${TITLE}_${DATE}" \
			-metadata date="${YEAR}" \
			-metadata genre="Radio" \
			-metadata grouping="${GROUP}" \
			-metadata album="${ALBUM}" \
			-metadata artist="${ARTIST}" \
			"${RECPATH}/${OUTFILE}.m4a"
	fi
	mv "${RECFILE}" "${RECPATH}/${OUTFILE}.ts"
fi

on_exit
