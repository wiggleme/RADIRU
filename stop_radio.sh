#!/bin/bash
MPLAYPID=`pidof mplayer`
LOOPCNT=0
MODLOOP=0
while [ ${LOOPCNT} -lt 60 ]
do
        MPLAYPID=`pidof mplayer`
        if [ ! ${MPLAYPID} ]; then
                break
        fi
        if [ ${MODLOOP} -eq 0 ]; then
        	PLAYPID=`ps -A|grep nhk_radio|awk '{ print $1 }'`
        	#DLPID=`ps -A|grep dl_radio|awk '{ print $1 }'`
		echo "m:${MPLAYPID} p:${PLAYPID} d:${DLPID}"
                #kill -INT "${DLPID}"
                kill -INT "${MPLAYPID}"
                kill -INT "${PLAYPID}"
        fi
        sleep 1
        LOOPCNT=`expr ${LOOPCNT} + 1`
done

