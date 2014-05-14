#!/bin/sh

set -eu

status () {
  echo "---> ${@}" >&2
}

set -x
: LDAP_ADMIN_PWD=${LDAP_ADMIN_PWD}
: LDAP_DOMAIN=${LDAP_DOMAIN}
: LDAP_ORGANISATION=${LDAP_ORGANISATION}

############ Base config ############
if [ ! -e /var/lib/ldap/docker_bootstrapped ]; then
  status "configuring slapd for first run"

  cat <<EOF | debconf-set-selections
slapd slapd/internal/generated_adminpw password ${LDAP_ADMIN_PWD}
slapd slapd/internal/adminpw password ${LDAP_ADMIN_PWD}
slapd slapd/password2 password ${LDAP_ADMIN_PWD}
slapd slapd/password1 password ${LDAP_ADMIN_PWD}
slapd slapd/dump_database_destdir string /data/backups/slapd-VERSION
slapd slapd/domain string ${LDAP_DOMAIN}
slapd shared/organization string ${LDAP_ORGANISATION}
slapd slapd/backend string HDB
slapd slapd/purge_database boolean true
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/no_configuration boolean false
slapd slapd/dump_database select when needed
EOF

  dpkg-reconfigure -f noninteractive slapd

  touch /var/lib/ldap/docker_bootstrapped

else
  status "found already-configured slapd"
fi

############ Dynamic config ############
slapd -h "ldap:/// ldapi:///" -u openldap -g openldap
chown -R openldap:openldap /etc/ldap

# TLS
if [ -e /etc/ldap/ssl/ldap.crt ] && [ -e /etc/ldap/ssl/ldap.key ] && [ -e /etc/ldap/ssl/ca.crt ]; then
  status "certificates found"

  chmod 600 /etc/ldap/ssl/ldap.key

  # create DHParamFile if not found
  [ -f /etc/ldap/ssl/dhparam.pem ] || openssl dhparam -out /etc/ldap/ssl/dhparam.pem 2048

  ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/ldap/config/auto/tls.ldif 

  # add fake dnsmasq route to certificate cn
  cn=$(openssl x509 -in /etc/ldap/ssl/ldap.crt -subject -noout | sed -n 's/.*CN=\(.*\).\^*/\1/p')
  echo "127.0.0.1	" $cn >> /etc/dhosts

fi

# Replication
# todo

# Other config files
for f in $(find /etc/ldap/config -maxdepth 1 -name \*.ldif -type f); do
  status "Processing file ${f}"
  ldapmodify -Y EXTERNAL -H ldapi:/// -f $f
done

echo "pkill slapd"
pkill slapd
sleep 5

status "starting slapd on default port 389"
set -x
exec /usr/sbin/slapd -h "ldap:///" -u openldap -g openldap -d -1
