## docker-openldap

Fork of : https://github.com/osixia/docker-openldap

### How to use tls

Add `-v some/host/dir:/data` and `--dns=127.0.0.1` to the run command.

/data/etc
/data/db
/data/log

`/data/etc` must contain a least 3 files :
- `ca.crt` certificate authority certificate
- `ldap.crt` ldap server certificate
- `ldap.key` ldap server certificate private key

and optionaly `dhparam.pem` this file is genereted automaticaly if not present.

`--dns=127.0.0.1` allow to use the certificate cn correctly.


### Example

    docker run --dns=127.0.0.1 \
               -v /data/ldap/db:/var/lib/ldap \
               -v /data/ldap/config:/etc/ldap/slapd.d \
               -v /data/ldap/ssl/:/etc/ldap/ssl \
               -v /data/ldap/log/:/var/log \
               -e LDAP_DOMAIN=example.com \
               -e LDAP_ORGANISATION="Example Corp." \
               -e LDAP_ROOTPASS=toor \
               -p 389:389 -d osixia/openldap
