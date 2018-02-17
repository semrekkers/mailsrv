#!/bin/bash
set -e

SSL_CERT=/etc/ssl/mailsrv
VMAIL=/var/vmail
DKIM=/etc/opendkim

echo "Configuring mailsrv..."

# Checks
if [[ ! -d $SSL_CERT ]]; then
    printf "ERROR: No TLS certificate was found, please make sure these files exists:\n\t"$SSL_CERT"/fullchain.pem (certificate)\n\t"$SSL_CERT"/privkey.pem (private key)\n"
    exit 1
fi

if [[ ! -d $VMAIL ]]; then
    printf "WARNING: Mail directory is not mapped.\n\tCreate a volume for "$VMAIL"\n"
    # Create this directory
    mkdir -p $VMAIL
fi

if [[ ! -d $DKIM ]]; then
    printf "WARNING: DKIM directory is not mapped.\n\tCreate a volume for "$DKIM"\n"
    # Create this directory
    mkdir -p $DKIM
fi

if [[ $(stat -c "%U:%G" $VMAIL) != "vmail:vmail" ]]; then
    printf "WARNING: Mail directory has wrong owner\n"
    chown -R vmail:vmail $VMAIL
fi

printf $HOSTNAME"\n" > /etc/mailname
chown -R vmail:dovecot /etc/dovecot

expand_var () {
    sed -i "s#\$"$2"#"$3"#g" $1
}

eval_config () {
    expand_var $1 HOSTNAME          $HOSTNAME
    expand_var $1 MYSQL_USER        $MYSQL_USER
    expand_var $1 MYSQL_PASSWORD    $MYSQL_PASSWORD
    expand_var $1 MYSQL_HOST        $MYSQL_HOST
    expand_var $1 MYSQL_DB          $MYSQL_DB
}

# Evaluate configs
eval_config /etc/postfix/main.cf
eval_config /etc/postfix/mysql-virtual-alias-maps.cf
eval_config /etc/postfix/mysql-virtual-mailbox-domains.cf
eval_config /etc/postfix/mysql-virtual-mailbox-maps.cf

eval_config /etc/dovecot/conf.d/10-auth.conf
eval_config /etc/dovecot/conf.d/10-mail.conf
eval_config /etc/dovecot/conf.d/10-master.conf
eval_config /etc/dovecot/conf.d/10-ssl.conf
eval_config /etc/dovecot/conf.d/15-lda.conf
eval_config /etc/dovecot/conf.d/auth-sql.conf.ext
eval_config /etc/dovecot/dovecot-sql.conf.ext

eval_config /etc/opendkim.conf

echo "Done configuring."