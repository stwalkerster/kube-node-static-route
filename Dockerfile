FROM ubuntu:noble

RUN apt-get update && \
    apt-get install -y iproute2 && \
    rm -rf /var/lib/apt/lists/*

COPY routes.sh /usr/local/bin/routes.sh
RUN chmod +x /usr/local/bin/routes.sh

ENV subnets=""
ENV gateway=""

ENTRYPOINT ["/usr/local/bin/routes.sh"]