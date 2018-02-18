#!/bin/bash
set -e

if [[ ! -f /etc/mailsrv/.configured ]]; then
    # Configure the box
    configure-mailsrv.sh
    mkdir /etc/mailsrv
    touch /etc/mailsrv/.configured
fi

exec supervisord -c /etc/supervisor/supervisord.conf
