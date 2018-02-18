#!/bin/bash
set -e

echo "Configuring mailsrv..."

MAIL_CERT=${MAIL_CERT:-/etc/ssl/mailsrv/fullchain.pem}
MAIL_KEY=${MAIL_KEY:-/etc/ssl/mailsrv/privkey.pem}
MAIL_VMAIL=/var/vmail
MAIL_DKIM=/etc/opendkim

# Checks
if [[ ! -f $MAIL_CERT || ! -f $MAIL_KEY ]]; then
    echo -e "ERROR: Invalid TLS configuration, please make sure these files exists:"
    echo -e "\t$MAIL_CERT (certificate)"
    echo -e "\t$MAIL_KEY (private key)"
    exit 1
fi

if [[ ! -d $MAIL_VMAIL ]]; then
    echo -e "WARNING: Mail directory is not mapped."
    echo -e "\tYou should create a volume for '"$MAIL_VMAIL"'."
    # Create this directory
    mkdir -p $MAIL_VMAIL
fi

if [[ ! -d $MAIL_DKIM ]]; then
    echo -e "WARNING: DKIM directory is not mapped."
    echo -e "\tYou should create a volume for '"$MAIL_DKIM"'."
    # Create this directory
    mkdir -p $MAIL_DKIM
    # And files
    touch /etc/opendkim/TrustedHosts
    touch /etc/opendkim/SigningTable
    touch /etc/opendkim/KeyTable
fi

if [[ $(stat -c "%U:%G" $MAIL_VMAIL) != "vmail:vmail" ]]; then
    printf "WARNING: Mail directory has wrong owner\n"
    chown -R vmail:vmail $MAIL_VMAIL
fi

echo $HOSTNAME > /etc/mailname
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
    expand_var $1 MAIL_CERT         $MAIL_CERT
    expand_var $1 MAIL_KEY          $MAIL_KEY
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
