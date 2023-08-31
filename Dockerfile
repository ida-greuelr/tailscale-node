FROM --platform=$BUILDPLATFORM ubuntu:jammy
LABEL org.opencontainers.image.authors="rene.greuel@ida-sds.com"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends ca-certificates curl jq && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV TS_UP="true"
ENV TS_AUTHKEY="tskey-auth-XYZ"
ENV TS_HOSTNAME="$HOST"
ENV TS_ACCEPT_ROUTES="true"
ENV TS_ACCEPT_DNS="true"
ENV TS_CERT="false"
ENV TS_EXTRA_ARGS=""
ENV TSD_EXTRA_ARGS=""

RUN curl -fsSL https://tailscale.com/install.sh | sh

COPY docker-entrypoint.sh /

# Run on container startup.
ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "bash" ]