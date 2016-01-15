FROM centos:7
MAINTAINER Robin Dietrich <me@invokr.org>

# Install postfix, dovecot, and supervisor
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && yum update -y && yum install -y cronie cyrus-sasl dovecot opendkim opendmarc postfix python-setuptools rsyslog wget  \
 && easy_install pip && pip install supervisor mako && yum clean all

# For debugging
# RUN yum install -y telnet vim mailx

# Environment variables
ENV POSTFIX_HOSTNAME="mail.domain.tld" POSTFIX_DOMAIN="domain.tld" POSTFIX_DESTINATION=""
ENV POSTFIX_VHOSTS "domain1.tld,domain2.tld"
ENV POSTFIX_VMAPS "info@domain1.tld  domain1.tld/info/,info@domain2.tld  domain2.tld/info/"

# Add scripts and config
ADD scripts /opt/bin
ADD config /opt/config

# Add group and user for virtual mail
RUN groupadd -g 10000 vmail && useradd -m -d /vmail -u 10000 -g 10000 -s /sbin/nologin vmail

# Add secure directory
RUN mkdir /secure

# Configure supervisord
ADD config/supervisor/supervisord.conf /etc/supervisord.conf

# Configure rsyslogd
RUN sed -i 's/^\$ModLoad imjournal/#\$ModLoad imjournal/' /etc/rsyslog.conf \
 && sed -i 's/^\$OmitLocalLogging on/\$OmitLocalLogging off/' /etc/rsyslog.conf \
 && sed -i 's/^\$IMJournalStateFile imjournal.state/#\$IMJournalStateFile imjournal.state/' /etc/rsyslog.conf \
 && sed -i 's/^\$SystemLogSocketName/#\$SystemLogSocketName/' /etc/rsyslog.d/listen.conf

# Configure opendmarc
ADD config/opendmarc/opendmarc.conf /etc/opendmarc.conf
RUN ln -s /opt/bin/update-tld-names /etc/cron.weekly/ && /opt/bin/update-tld-names

# Configure postfix
ADD config/postfix /etc/postfix/

# Configure dovecot
ADD config/dovecot /etc/dovecot

RUN /opt/bin/config-apply /etc/postfix/main.cf \
 && /opt/bin/config-apply /etc/postfix/vhosts \
 && /opt/bin/config-apply /etc/postfix/vmaps \
 && postmap /etc/postfix/vmaps \
 && /opt/bin/gentls

# Start our init system
#CMD ['/opt/bin/dumb-init', '/usr/bin/supervisord -c /etc/supervisord.conf']
