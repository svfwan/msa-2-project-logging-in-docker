1. Project, configure custom DNS and load balancing
Two apps, hosted by the same docker host, communicate with each other. For the sake of
availability, multiple instances of the apps are deployed and proxied by a load balancer (nginx). The
apps should be reachable under particular domain names, which can be realized by a proper (docker
internal) DNS server.
Prerequisites:
• some local docker installation (docker CLI for Linux or Docker Desktop for MAC and
Windows)
• docker compose installed/enabled
How to setup the system:
Tow apps (app1, app2) are created providing a REST endpoint each (for instance you can use
something from here https://github.com/AndiKleini/dockersamples as starting point and extend it
properly, but it is up to you choosing something else). The app1 exposes a GET endpoint that
triggers a call to another GET endpoint provided by app2. Once app2, which is typically called by
app1) returned with it’s response, app1 will process the received data and generate a proper output
for the initial caller.
In order to increase the availability of the system both apps will be placed behind a load balancer
and scaled up to 4 instances each. Separate load balancers, realized as pairs of nginx containers
(each load balancer is scaled up to two containers for availability reasons), have to be used for app1
and app2.
A DNS server should be used for resolving the endpoints of app1 and app2. First you can put the
apps into a custom network so that static IP addresses for the containers are supported. The
containers of the load balancers should be reachable under the name app1@msa.com and
app2@msa.com, which has to be specified in the configuration of the used DNS server (Bind9,
CoreDNS … compare linked articles below).
Following graphics illustrates the situation:
What will we do:
Create the system as described above. There is no need for complex logic in app1 and app2. Just
make sure that a call to app1 includes a call to app2 and make sure that the created DNS is used.
When are you done:
• Docker compose file and proper Docker files for the system are in place.
• A brief instruction how to test the application
• Make sure that the app containers are balanced and that the DNS is used for name
resolutions.
For supporting articles look here:
• https://medium.com/@eugen.iordatiev/a-detailed-guide-on-setting-up-a-local-dns-serverusing-docker-32aaba1105cc
• https://medium.com/nagoya-foundation/running-a-dns-server-in-docker-61cc2003e899
• https://medium.com/@nidhinbabukuttan/load-balancing-containers-with-nginx-a-practicalexample-1d6393885fb

---

2. Project, monitor app with Prometheus
An app running on a docker host should be monitored by Prometheus.
Prerequisites:
• some local docker installation (docker CLI for Linux or Docker Desktop for MAC and
Windows)
• docker compose installed/enabled
How to monitor container:
A container can be monitored by Prometheus by exposing a proper metrics endpoint (HTTP
method GET). By periodically fetching the metrics from the endpoint (scraping, scrape jobs) the
metrics are stored within Prometheus time series database. By connecting Grafana the metrics can
be displayed in some minimal dashboard.
What will we do:
In this example we will deploy Prometheus service to our local docker node. Next we will
configure a suitable scrape job in order to get metrics from some app which you can get from
https://github.com/AndiKleini/dockersamples and extend it by some metrics exporting endpoint.
You can also create a fresh app on your own if you like.
The metrics calls_count, that is simply counting the number of calls handled by any endpoint of the
API starting from the last scrape fetch (this means you can reset the counter on each fetch and start
counting from zero) should be visualized by a minimal Grafana dashboard.
When are you done:
• Add a metrics exporting endpoint to your API
• Deploy Prometheus and Grafana
• Configure scrape job for the endpoint provided above
• Display the metrics in Grafana (no special Dashboard is required).
• Submit a compose file and instructions for verification

For supporting articles look here:
• https://github.com/docker/awesome-compose/tree/master/prometheus-grafana (Grafana
and Prometheus docker compose)
• https://prometheus.io/docs/tutorials/getting_started/

---

3. Project, logging in docker
The challenge of this project is to add logging capabilities to a local docker host.
Prerequisites:
• some local docker installation (docker CLI for Linux or Docker Desktop for MAC and
Windows)
• docker compose installed/enabled
How to create log messages in a container:
Generating log files in a docker container is very easy as the messages only have to be written to the
standard out stream (stout) of the application.
In fact this means
Console.Write ("Some message") for C#,
System.out.println("Some message") for Java and
console.log("Some message") for node.js
will push per default "Some message" to the docker logs.
What will we do:
In this example we will add logging capabilities to an already existing docker node. To keep things
simple we will deploy the tools Promtail, Loki and Grafana by proper docker compose files to our
docker node.
Promtail log server will be configured collecting the local docker logs and sending these to loki.
Loki will do proper indexing of the data and integrates seamlessly with Grafana. At the end
Grafana can display the log files properly in some minimal dashboard (compare figure 1).
As application on our node you can take a suitable API from here
https://github.com/AndiKleini/dockersamples and add some log messages for testing. Alternatively
you can deploy any other application as container as well.
Figure 1: Architecture
When are you done:
• Add a log message to your API that can be triggered easily by some client (e.g.: write a
message on each call).
• Collect the system logs by Promtail
• Send the collected logs to Loki
• Display the logs in any way in Grafana (no special Dashboard is required).
• Submit a compose file and instructions for verification
For supporting articles look here:
• https://medium.com/django-unleashed/get-visibility-into-your-docker-container-logswith-grafana-loki-of-a-django-application-9584bddfe540 (Promtail – Loki – Grafana
example)
• https://docs.docker.com/config/containers/logging/configure/ (Docker log drivers)
