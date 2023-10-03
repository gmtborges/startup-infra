FROM alpine

WORKDIR /fluent-bit/etc

COPY fluent-bit.conf .
COPY parsers.conf .

ENTRYPOINT ["tail", "-f", "/dev/null"]

