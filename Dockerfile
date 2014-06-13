FROM peterrosell/docker-ubuntu-base:trusty
MAINTAINER Peter Rosell <peter.rosell@gmail.com>

# Lightly base on https://github.com/osixia/docker-openldap

# Default configuration: can be overridden at the docker command line
ENV LDAP_ADMIN_PWD changeme
ENV LDAP_ORGANISATION Company Inc
ENV LDAP_DOMAIN example.com
ENV LOG_LEVEL -1

ENV BOOTSTRAP no

# /!\ To store the data outside the container, mount /var/lib/ldap as a data volume
# add -v /some/host/directory:/var/lib/ldap to the run command

# Expose ldap default port
EXPOSE 389

CMD /usr/bin/init_ldap.sh

### Install openldap (slapd) and ldap-utils
RUN apt-get -y update && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get install -y slapd ldap-utils openssl

# Create TLS certificats directory
#RUN mkdir /etc/ldap/ssl

# Add config directory 
RUN mkdir /etc/ldap/config
ADD config /etc/ldap/config
ADD slapd.conf /etc/ldap/slapd.conf
ADD slapd_logrotate.conf /etc/logrotate.d/ldap
#RUN mkdir /var/log/ldap/log && chown openldap:openldap /var/log/ldap/log

### Remove the original ldap's directories and replace it with external volume
RUN mv /var/lib/ldap /var/lib/ldap.original
RUN mv /etc/ldap /etc/ldap.original

RUN mkdir -p /ext/etc && mkdir -p /ext/data && mkdir -p /ext/log

RUN ln -s /ext/etc /etc/ldap && ln -s /ext/data/db /var/lib/ldap && ln -s /ext/log /var/log/ldap

#RUN chown openldap:openldap /var/lib/ldap

# Clear out the local repository of retrieved package files
#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add slapd deamon
ADD bin/init_ldap.sh /usr/bin/init_ldap.sh
