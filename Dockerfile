FROM ubuntu:xenial
LABEL maintainer "Sem Rekkers <rekkers.sem@gmail.com>"

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
        supervisor \
        rsyslog \
        postfix \
        postfix-mysql \
        dovecot-core \
        dovecot-imapd \
        dovecot-lmtpd \
        dovecot-mysql \
        opendkim \
        opendkim-tools

RUN groupadd -g 5000 vmail && useradd -g vmail -u 5000 vmail -d /var/vmail

COPY config/postfix/    /etc/postfix/
COPY config/dovecot/    /etc/dovecot/
COPY config/supervisor/ /etc/supervisor/
COPY config/etc/        /etc/

COPY scripts/* /usr/local/bin/
ENTRYPOINT [ "entrypoint.sh" ]
