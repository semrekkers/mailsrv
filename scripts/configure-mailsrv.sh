#!/bin/bash
set -e

# Postfix TLS
if [[ -d /etc/ssl/mailsrv ]]; then
    postconf -e smtpd_use_tls=yes
    postconf -e smtpd_tls_cert_file=/etc/ssl/mailsrv/fullchain.pem
    postconf -e smtpd_tls_key_file=/etc/ssl/mailsrv/privkey.pem
    postconf -e smtpd_tls_auth_only=yes
else
    echo "WARNING: No TLS certificates."
fi

# Postfix SASL
postconf -e smtpd_sasl_type=dovecot
postconf -e smtpd_sasl_path=private/auth
postconf -e smtpd_sasl_auth_enable=yes
postconf -e smtpd_recipient_restrictions=permit_sasl_authenticated,permit_mynetworks,reject_unauth_destination
postconf -e mydestination=localhost

postconf -e virtual_transport=lmtp:unix:private/dovecot-lmtp
postconf -e virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
postconf -e virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
postconf -e virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf

# Virtual mailbox
cat > /etc/postfix/mysql-virtual-mailbox-domains.cf <<EOF
user = $MYSQL_USER
password = $MYSQL_PASSWORD
hosts = $MYSQL_HOSTS
dbname = $MYSQL_DB
query = SELECT 1 FROM virtual_domains WHERE name='%s'
EOF

cat > /etc/postfix/mysql-virtual-mailbox-maps.cf <<EOF
user = $MYSQL_USER
password = $MYSQL_PASSWORD
hosts = $MYSQL_HOSTS
dbname = $MYSQL_DB
query = SELECT 1 FROM virtual_users WHERE email='%s'
EOF

cat > /etc/postfix/mysql-virtual-alias-maps.cf <<EOF
user = $MYSQL_USER
password = $MYSQL_PASSWORD
hosts = $MYSQL_HOSTS
dbname = $MYSQL_DB
query = SELECT destination FROM virtual_aliases WHERE source='%s'
EOF

postconf -M submission/inet="submission   inet   -   -   -   -   -   smtpd"
postconf -P "submission/inet/syslog_name=postfix/submission"
postconf -P "submission/inet/smtpd_tls_security_level=encrypt"
postconf -P "submission/inet/smtpd_sasl_auth_enable=yes"
postconf -P "submission/inet/smtpd_recipient_restrictions=permit_sasl_authenticated,reject_unauth_destination"

# Dovecot
set_config () {
    grep -q '^'$2 $1 && sed -i 's/^'$2'.*/'$2'='$3'/' $1 || echo $2'='$3 >> $1
}
