#!/bin/bash

#BSD uses 'stat -f %z'
#Debian uses 'stat -c %s'

if [[ $1 == "" ]]; then
  echo "Usage: $0 [dest_file] [orig_file]"
  exit 1
fi

DEST_FILE=$1
ORIG_FILE=$2
DEST_ETA="false"

if stat -c %s "$0" > /dev/null 2>&1; then
  STAT_OPTS="-c %s"
elif stat -f %z "$0" > /dev/null 2>&1; then
  STAT_OPTS="-f %z"
else
  echo "Error: cannot figure out your stat formatting"
  exit 1
fi

if [ -f "$ORIG_FILE" ]; then
  ORIG_SIZE=$(stat "$STAT_OPTS" "$ORIG_FILE")
  DEST_ETA="true"
else
  DEST_ETA="false"
fi
SLEEP=1
DEST_SIZE_1=$(stat "$STAT_OPTS" "$DEST_FILE")
DEST_SIZE_2SEC1=$DEST_SIZE_1
for I in $(seq 1 10); do
  sleep $SLEEP
  DEST_SIZE_2=$(stat "$STAT_OPTS" "$DEST_FILE")
  SPEED=$(echo "($DEST_SIZE_2 - $DEST_SIZE_1) / $SLEEP" | bc -l)
  DEST_SIZE_1=$(stat "$STAT_OPTS" "$DEST_FILE")
  SPEED_PER_K=$(echo "$SPEED/1000" | bc -l)
  echo "1 second averaged speed: $SPEED_PER_K kb/sec"
  if [ "$(echo "$I%2" | bc)" == 0 ]; then
    SPEED_2SEC=$(echo "($DEST_SIZE_2 - $DEST_SIZE_2SEC1) / (2*$SLEEP)" | bc -l)
    SPEED_PER_K=$(echo "$SPEED_2SEC/1000" | bc -l)
    echo "2 second averaged speed: $SPEED_PER_K kb/sec"
    DEST_SIZE_2SEC1=$(stat "$STAT_OPTS" "$DEST_FILE")
  fi
  if [[ $DEST_ETA == "true" ]]; then
    PERCENT_COMPLETE=$(echo "$DEST_SIZE_2/$ORIG_SIZE" | bc -l)
    ETA=$(echo "$ORIG_SIZE/$SPEED/60" | bc -l)
    echo "PERCENT: $PERCENT_COMPLETE %"
    echo "ETA: $ETA minutes"
  fi
done
