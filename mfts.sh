#!/bin/bash

if [[ $1 == "" ]]; then
  echo "Usage: $0 [dest_file] [orig_file]"
  exit 1
fi

DEST_FILE=$1
ORIG_FILE=$2
DEST="false"

if [ -f "$ORIG_FILE" ]; then
	ORIG_SIZE=$(stat -c %s "$ORIG_FILE")
	DEST="true"
else
	DEST="false"
fi
SLEEP=1
DEST_SIZE_1=$(stat -c %s "$DEST_FILE")
DEST_SIZE_2SEC1=$DEST_SIZE_1
for I in $(seq 1 10); do
  sleep $SLEEP
  DEST_SIZE_2=$(stat -c %s "$DEST_FILE")
  SPEED=$(echo "($DEST_SIZE_2 - $DEST_SIZE_1) / $SLEEP" | bc -l)
  DEST_SIZE_1=$(stat -c %s "$DEST_FILE")
	SPEED_PER_K=$(echo "$SPEED/1000" | bc -l)
  echo -n "1 second averaged speed: $SPEED_PER_K kb/sec"
  if [ "$(echo "$I%2" | bc)" == 0 ]; then
    SPEED_2SEC=$(echo "($DEST_SIZE_2 - $DEST_SIZE_2SEC1) / (2*$SLEEP)" | bc -l)
	  SPEED_PER_K=$(echo "$SPEED_2SEC/1000" | bc -l)
    echo -n "2 second averaged speed: $SPEED_PER_K kb/sec"
    DEST_SIZE_2SEC1=$(stat -c %s "$DEST_FILE")
  fi
	if [[ $DEST == "true" ]]; then
    PERCENT_COMPLETE=$(echo "$DEST_SIZE_2/$ORIG_SIZE" | bc -l)
    ETA=$(echo "$ORIG_SIZE/$SPEED/60" | bc -l)
		echo -n "PERCENT: $PERCENT_COMPLETE %"
	  echo -n "ETA: $ETA minutes"
	fi
done
