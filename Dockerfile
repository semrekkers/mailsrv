FROM ubuntu:xenial
LABEL maintainer "Sem Rekkers <rekkers.sem@gmail.com>"

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
        nano \
        supervisor \
        postfix \
        postfix-mysql \
        dovecot-core \
        dovecot-imapd \
        dovecot-lmtpd \
        dovecot-mysql \
        opendkim \
        opendkim-tools

COPY scripts/* /usr/local/bin/
ENTRYPOINT [ "entrypoint.sh" ]
