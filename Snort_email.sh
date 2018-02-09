#! /bin/bash


SNORTPATH=/var/log/snort
ALERTA=$SNORTPATH/alert
DUMPFILE=$(ls -lrt $SNORTPATH | awk '{print $9}' | tail -n2 | grep -v alert | grep -v pid)
### CHANGE ME PLZ ###
EMAIL=rtumaian@truss.com.uy
###		 ###

if [ -z "$DUMPFILE" ]; then
        echo "$(ls -rt $SNORTPATH | tail -n5)"
        echo -n "Seleccione archivo con paquetes: "; read DUMPFILE
fi
ALERTA=/var/log/snort/alert
while true; do
        while /usr/local/bin/inotifywait -e MODIFY $ALERTA; do
                MSG=$(tail -n1 $ALERTA);

                # IP_DESTINY:DESTINY_PORT
                IP_DST_DSTP=$(echo $MSG | awk -F "->" '{print $2}')
		# IP_DESTINO
                IP_DST=$(echo $IP_DST_DSTP | awk -F ":" '{print $1}' | awk '{print $NF}')
                
		# PUERTO_DST
                DSTP=$(echo $IP_DST_DSTP | awk -F ":" '{print $2}')


                # IP_SOURCE:SOURCE_PORT
                IP_SRC_SRCP=$(echo $MSG | awk -F "->" '{print $1}' | awk '{print $NF}')

                # IP_SOURCE
                IP_SRC=$(echo $IP_SRC_SRCP | awk -F ":" '{print $1}')

                # SOURCE_PORT
                SRCP=$(echo $IP_SRC_SRCP | awk -F ":" '{print $2}')

                CONTENIDOPKG=$(tcpdump -r $SNORTPATH/$DUMPFILE -n -vvv -A "src $IP_SRC && src port $SRCP && dst $IP_DST && dst port $DSTP")



                echo "$MSG 

Contenido:

$CONTENIDOPKG" | mail -s SNORTC $EMAIL

        done

done
