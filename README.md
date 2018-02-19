# Mailsrv

Mailsrv (_mailserver_) is an easy-to-setup, single container mail server that supports SMTP, POP3 and IMAP. Under the hood it uses Postfix, Dovecot and OpenDKIM to handle your mail fast and secure.

## Requirements

The only things you need are a TLS certificate and a MySQL database! Configuration (of Postfix, Dovecot, etc) is automatically done for you.

## Getting started

This will only take a few minutes!

### Step 1

Setup your database. If you don't have a running instance of MySQL yet, use Docker to set one up: `docker run -d --name mysql-server -e MYSQL_ROOT_PASSWORD=<new password> mysql`.

Create a database for your email accounts (e.g. `mail_accounts`). Then, execute the `database/seed.sql` script. If you just created a new instance of MySQL from above, you can access your instance using `docker exec -it mysql-server mysql -u root -p` and type in your password. If you want, you can just copy/paste the contents of `database/seed.sql` into the monitor.

### Step 2

Setup your email domains, run `INSERT INTO virtual_domains (name) VALUES ('<your domain>');` for each domain you want to use (lookup the id's for the next step).

### Step 3

Setup your email accounts. run `INSERT INTO virtual_users (domain_id, email, password) VALUES (<domain id>, '<email>', ENCRYPT('<password>', CONCAT('$6$', SUBSTRING(SHA(RAND()), -16))));`.

### Step 4

Create a TLS certificate (it's better to use Let's Encrypt): `openssl req -x509 -newkey rsa:2048 -keyout privkey.pem -out cert.pem -nodes -days 365`.

### Step 5

Run mailsrv!

```
docker run -d --name mail-server \
    --link mysql-server \
    -v /path/to/tls/certificates:/etc/ssl/mailsrv \
    -e MYSQL_HOST=mysql-server \
    -e MYSQL_DB=mail_accounts \
    -e MYSQL_USER=root \
    -e MYSQL_PASSWORD=<MySQL root password> \
    -p 25:25 -p 465:465 -p 587:587 -p 993:993 -p 995:995 \
    semrekkers/mailsrv
```

**NOTE:** From a security point of view, this is not a good practise. You must have some experience/knowledge about TLS, SMTP, IMAP, POP3, DKIM, SPF and DMARC to use this Docker image correctly.

## Environment variables

|Name               |Description                            |Default                    |
|-------------------|---------------------------------------|---------------------------|
|MAIL_TLS_DIR       |Base directory of your TLS certificate.|`/etc/ssl/mailsrv`         |
|MAIL_CERT          |TLS certificate to use.                |`$MAIL_TLS_DIR/cert.pem`   |
|MAIL_KEY           |Private key to use.                    |`$MAIL_TLS_DIR/privkey.pem`|
|MYSQL_HOST         |MySQL host.                            |_Required_                 |
|MYSQL_DB           |MySQL database.                        |_Required_                 |
|MYSQL_USER         |MySQL username.                        |_Required_                 |
|MYSQL_PASSWORD     |MySQL password.                        |_Required_                 |
|MAIL_DKIM_SELECTOR |DKIM selector.                         |_Random string_            |
|MAIL_DKIM_KEY      |DKIM private key.                      |`/etc/opendkim/privkey.pem`|

## Details

What you typically only need is a (valid) TLS certificate, a MySQL database and a DKIM key pair. You must configure SPF, DKIM (DNS record) and DMARC yourself. This image uses a system-wide DKIM key pair to sign all outgoing mail.

## Why this image?

If you configure it correctly, you have a nice and small email server that can handle most email traffic for personal or small business use. You can easily replace/update it because you don't have to touch any configuration file, all your email accounts are stored in one database.

## How about spam filters?

Coming soon (maybe?)

## Contributions and issues

Please open up an issue on GitHub!
