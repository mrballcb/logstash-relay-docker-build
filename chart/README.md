# Chart for Logstash Relay
This chart will do the following:

* Deploy a logstash instance in a relay configuration.
* Deploy a configmap mounted as a volume for the certs.
* Deploy a service so it can be resolved with a single hostname throughout the Kube cluster.

## Design principles
This chart is designed to function solely as a logstash relay between local trusted hosts
using plaintext inputs for either file/metricbeats or raw JSON input, and forwards it on
to your central ELK stack using an encrypted raw JSON connection.  You are expected to
generate the CA, a client key, and self-sign the cert between your forwarder and the
central ELK stack.

"Local trusted hosts" include other pods in the same Kube cluster, or other VM's in the
same VPC as your Kube cluster, or other hosts that are VPN'd to the same VPC as your
Kube cluster.  If a host's traffic has to cross someone else's network, then that host
is conceptually not part of the "local trusted host" group.  You need to either configure
that host to send directly to your central ELK stack with standard encryption config, or
put a logstash-relay in the vicinity of that host (so that encryption occurs between the
relay and the central ELK stack).

A service is deployed that uses the name and the namespace to make the pod accessible
with one common name throughout the entire cluster.  For example, if your name is
"logstash-relay" and you deployed it to namespace "dev", then the service DNS would
be "logstash-relay.dev"  This DNS name will be reachable to any pod in the Kube
cluster.  The FQDN is actually "logstash-relay.dev.svc.cluster.local", but typically
"svc.cluster.local" is in the /etc/resolv.conf which allows you to use the shorter
service DNS value.

## Build Chart Dependencies
There are no other chart dependencies.

## Installing the Chart
Edit the `chart/values.yaml` and make any required changes to the environment variables section.
Then install the chart with the release name *logstash-relay*:
```bash
$ helm install chart/ \
    --name logstash-relay \
    --set uniqueStackId=DEV
```

## Alternative Chart installation
Copy the `chart/values.yaml` to `chart/values-DEV.yaml` and make any required changes to the
environment variables section and the uniqueStackId.  Then install the chart with the release
name *logstash-relay*:
```bash
$ helm install chart/ \
    --name logstash-relay \
    -f chart/values-DEV.yaml
```
Git is configured to ignore chart/values-\*.yaml so git will not complain about this as an
untracked file.

## ConfigMap format
In `charts/example/configmap.yml` there is an example configmap if you want to use TLS
between your relay and your ELK stack.  It is advised you use TLS because not only do you
get encryption, it acts as an authenticator when you use the self created CA and sign
your own certs.

## Updating certs
This docker image nor this chart work for multiple certs.  Instead you launch multiple
instances, one with each cert listening on a different port.  So as you approach a cert
expiration you have to create second logstash ingestion point in your ELK stack with
a new cert, listening on a different port, and add that port to the load balancer.  Then
you have to create a second logstash-relay instance with a different name, configured to
ship to the new logstash port on the ELK stack.

