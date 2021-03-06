#!/bin/bash

## handle termination gracefully

_term() {
  echo "Terminating Elasticsearch"
  service elasticsearch stop
  exit 0
}

trap _term SIGTERM

rm -f /var/run/elasticsearch/elasticsearch.pid

chown -R elasticsearch:elasticsearch /snapshot

## start services
service elasticsearch start

counter=0
while [ ! "$(curl localhost:9201 2> /dev/null)" -a $counter -lt 30  ]; do
  sleep 1
  ((counter++))
  echo "waiting for Elasticsearch to be up ($counter/30)"
  cat /var/log/elasticsearch/elasticsearch.log
done

echo "Started"
tail -f /var/log/elasticsearch/elasticsearch.log &
wait
