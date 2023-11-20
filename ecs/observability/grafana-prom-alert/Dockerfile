FROM alpine

WORKDIR /etc/prometheus

COPY prometheus.yml .
COPY alert.rules .
COPY alertmanager.yml /etc/alertmanager/

ENTRYPOINT ["tail", "-f", "/dev/null"]

