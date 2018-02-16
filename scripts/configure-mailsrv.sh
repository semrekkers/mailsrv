#!/bin/bash
set -e

# Checks
if [[ ! -d /etc/ssl/mailsrv ]]; then
    printf "ERROR: No TLS certificate was found, please make sure these files exists:\n\t/etc/ssl/mailsrv/fullchain.pem (certificate)\n\t/etc/ssl/mailsrv/privkey.pem (private key)\n"
    exit 1
fi

if [[ ! -d /var/mail/vhosts ]]; then
    printf "WARNING: Mail directory is not mapped.\n\tCreate a volume for /var/mail/vhosts"
    # Create this directory
    mkdir -p /var/mail/vhosts
fi

expand_var () {
    sed -i "s#\$"$2"#"$3"#g" $1
}

eval_config () {
    expand_var $1 HOSTNAME          $HOSTNAME
    expand_var $1 MYSQL_USER        $MYSQL_USER
    expand_var $1 MYSQL_PASSWORD    $MYSQL_PASSWORD
    expand_var $1 MYSQL_HOSTS       $MYSQL_HOSTS
    expand_var $1 MYSQL_DB          $MYSQL_DB
}

# Evaluate configs
eval_config /etc/postfix/main.cf
eval_config /etc/postfix/mysql-virtual-mailbox-domains.cf
eval_config /etc/postfix/mysql-virtual-mailbox-maps.cf
eval_config /etc/postfix/mysql-virtual-alias-maps.cf

# TODO: Authorization part and vmail user