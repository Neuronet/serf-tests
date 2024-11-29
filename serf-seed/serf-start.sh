#!/bin/sh

set -m
set -e
set -x

serf agent -config-file=/config/serf-config.json &
sleep 5
i=0
while true;
do
  ln_cnt=$(serf members | grep alive | grep seed | wc -l )
  i=$((ln_cnt))
#  echo $i
  if [ $i -le 1 ];
  then
    echo "try to join"
    serf join serf-seed-service:7946
    sleep $((5 + $RANDOM%5))
  else
    echo "wait for 60 sec"
    sleep $((60 + $RANDOM%10))
  fi
done

wait
