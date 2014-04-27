FROM phusion/baseimage
MAINTAINER Bertrand Gouny <bertrand.gouny@osixia.fr>

# Default configuration: can be overridden at the docker command line
ENV LDAP_ROOTPASS toor
ENV LDAP_ORGANISATION Example Inc.
ENV LDAP_DOMAIN example.com
ENV WORKGROUP EXAMPLE

# Others environment variables 
ENV HOME /root
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# Resynchronize the package index files from their sources
RUN apt-get -y update

##### Install OpenLDAP and Samba #####
RUN apt-get install -y slapd samba ldap-utils smbldap-tools samba-doc

# OpenLDAP config file template 
ADD slapd.conf /usr/share/slapd/slapd.conf

# Samba config file template
ADD smb.conf /etc/samba/smb.conf

# Samba tools config file template
ADD smbldap.conf /etc/smbldap-tools/smbldap.conf

# Samba tools binding file template
ADD smbldap_bind.conf /etc/smbldap-tools/smbldap_bind.conf

RUN mkdir /etc/service/slapd
ADD slapd.sh /etc/service/slapd/run

RUN mkdir /etc/service/smbd
ADD smbd.sh /etc/service/smbd/run


# Clear out the local repository of retrieved package files
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 389

# To store the data outside the container, mount /var/lib/ldap as a data volume

