# Docker image for Logstash in a Relay configuration
A Docker container with the ElasticSearch Logstash server.

## Build:

docker build -t mrballcb/logstash-relay-docker-build:VERSION .

## Usage:

Usage with TLS:

```
export LOGSTASH_SSL_CONTENT='ssl_cacert => "/logstash/certs/cacert.pem"\n'\
'      ssl_key => "/logstash/certs/logstash.key"\n'\
'      ssl_cert => "/logstash/certs/logstash.pem"\n'\
'      ssl_verify => true'

docker run -d -p 5044:5044 -p 514:514/udp -p 8000:8000/udp \
  -v /path/to/certs:/logstash/certs \
  -e LOGSTASH_ENV=dev \
  -e INPUT_BEATS_PORT=5044 -e INPUT_SYSLOG_PORT=514 -e INPUT_JSON_PORT=8000 \
  -e OUTPUT_DEST_HOST=beats-logs.example.com -e OUTPUT_DEST_PORT=6000 \
  -e OUTPUT_SSL_ENABLE=true \
  -e OUTPUT_SSL_CONTENT="$LOGSTASH_SSL_CONTENT" \
  mrballcb/logstash-relay-docker-build
```

Usage without TLS:

```
docker run -d -p 5044:5044 -p 514:514/udp -p 8000:8000/udp \
  -e LOGSTASH_ENV=dev \
  -e INPUT_BEATS_PORT=5044 -e INPUT_SYSLOG_PORT=514 -e INPUT_JSON_PORT=8000 \
  -e OUTPUT_DEST_HOST=beats-logs.example.com -e OUTPUT_DEST_PORT=6000 \
  -e OUTPUT_SSL_ENABLE=false \
  mrballcb/logstash-relay-docker-build
```

## Description

This is designed to be used as a local relay to a centralized Logstash json
input to a centrallized ELK stack.  As such, there is a heavily templated
configuration file put in place at `/logstash/config/logstash.conf`.
You *MUST* pass in enivronment variables for the deploy script to replace
configuration items in that config file.

The configuration is designed with the following in mind:

1. You specify an environment.  It is a tag added to every relayed packet, it's not used
in hostnames or identifiers.
1. You specify the port for the beats input.  The input is not encrypted because it's
expected to be used within your VPC or Kube stack.
1. You specify the syslog port.  If you don't plan on sending logs to the relay using
syslog, just don't export the port.
1. The JSON input port is for your apps to just submit raw JSON metrics and you completely
control what your apps submit here.  If your apps don't submit raw JSON, just don't export
the port. 
1. You specify the Logstash server and port that you are relaying to.
1. You specify whether to use TLS encryption.  If you specify true, then you must provide
all of the TLS options.  It's also up to you to provide the content in the `/logstash/certs`
volume.  The TLS example above mounts a local directory, but you somehow have to manage
your own volumes with certificates.

## Variables

| Env Variable               | Description                             | Default              |
| -------------------------- | --------------------------------------- | -------------------- |
| `LOGSTASH_ENV`             | Descriptive tag added to JSON           | None                 |
| `INPUT_BEATS_PORT`         | Port for beats input to listen on       | None                 |
| `INPUT_SYSLOG_PORT`        | Port for syslog input to listen on      | None                 |
| `INPUT_JSON_PORT`          | Port for raw JSON input to listen on    | None                 |
| `OUTPUT_DEST_HOST`         | Host the JSON will be relayed to        | None                 |
| `OUTPUT_DEST_PORT`         | Port the JSON will be relayed to        | None                 |
| `OUTPUT_SSL_ENABLE`        | Use TLS? true/false                     | None                 |
| `OUTPUT_SSL_CONTENT`       | All TLS args/values if use TLS          | None                 |

## Credits

Adapted from original work done by:  pjpires@gmail.com
At:  [docker-logstash Docker Hub](https://hub.docker.com/r/pires/docker-logstash)
At:  [docker-jre Quay repo](https://quay.io/repository/pires/docker-jre/image/43fc561b8159b4e9f1be5300f5f057cfb0bf12cb76d971f037836473d357ab6e)
