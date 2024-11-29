FROM alpine:3.20.3

COPY ./serf_bin/linux_386/serf /usr/bin/serf
COPY ./serf-start.sh /serf-start.sh
