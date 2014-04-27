#!/bin/sh

set -eu

status () {
  echo "---> ${@}" >&2
}

set -x
: WORKGROUP=${WORKGROUP}
: LDAP_ROOTPASS=${LDAP_ROOTPASS}
: LDAP_DOMAIN=${LDAP_DOMAIN}

if [ ! -e /var/lib/ldap/docker_smbd_bootstrapped ]; then
  status "configuring smbd for first run"

LDAP_SUFFIX=$(cat /usr/share/slapd/slapd.conf | grep '^suffix' | tr -d 'suffix *"')
sed -i 's/@WORKGROUP@/'"${WORKGROUP}"'/' /etc/samba/smb.conf
sed -i 's/@LDAP_SUFFIX@/'"${LDAP_SUFFIX}"'/' /etc/samba/smb.conf

sed -i 's/@LDAP_ROOTPASS@/'"${LDAP_ROOTPASS}"'/' /etc/smbldap-tools/smbldap_bind.conf
sed -i 's/@LDAP_SUFFIX@/'"${LDAP_SUFFIX}"'/' /etc/smbldap-tools/smbldap_bind.conf

sed -i 's/@WORKGROUP@/'"${WORKGROUP}"'/' /etc/smbldap-tools/smbldap.conf
sed -i 's/@LDAP_SUFFIX@/'"${LDAP_SUFFIX}"'/' /etc/smbldap-tools/smbldap.conf
sed -i 's/@LDAP_DOMAIN@/'"${LDAP_DOMAIN}"'/' /etc/smbldap-tools/smbldap.conf

chmod 600 /etc/smbldap-tools/smbldap_bind.conf

  touch /var/lib/ldap/docker_smbd_bootstrapped
else
  status "found already-configured smbd"
fi

status "starting smbd"
set -x

