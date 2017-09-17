#!/bin/bash

echo "Logstash destination: ${OUTPUT_DEST_HOST}:${OUTPUT_DEST_PORT}"

# Not needed here, just boilerplate
internalIp="$(ip a | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')"
echo "Running on IP: ${internalIp}"

# More boilerplate, but needs dnsutils, not required for this deployment
#externalIp="$(dig +short myip.opendns.com @resolver1.opendns.com)"

cd /logstash
# Build the config file
for ARG in LOGSTASH_ENV \
           INPUT_BEATS_PORT INPUT_SYSLOG_PORT INPUT_JSON_PORT \
           OUTPUT_DEST_HOST OUTPUT_DEST_PORT \
           OUTPUT_SSL_ENABLE OUTPUT_SSL_CONTENT
do
  sed -i -e "s|__${ARG}__|${!ARG}|g" config/logstash.conf
done


bin/logstash -f config/logstash.conf
