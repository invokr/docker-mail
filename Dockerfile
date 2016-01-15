FROM centos:7
MAINTAINER Robin Dietrich

# Install postfix, dovecot, and supervisor
RUN yum update -y && yum install -y cyrus-sasl dovecot postfix python-setuptools rsyslog \
 && easy_install pip && pip install supervisor mako && yum clean all

# for debugging
# RUN yum install -y telnet vim mailx

# Environment variables
ENV POSTFIX_HOSTNAME="mail.domain.tld" POSTFIX_DOMAIN="domain.tld" POSTFIX_DESTINATION=""
ENV POSTFIX_VHOSTS "domain1.tld,domain2.tld"
ENV POSTFIX_VMAPS "info@domain1.tld  domain1.tld/info/,info@domain2.tld  domain2.tld/info/"

# Install scripts
ADD scripts/dumb-init /sbin/dumb-init
ADD scripts/postfix.sh /opt/postfix
ADD scripts/config-apply.py /opt/config-apply
ADD scripts/gentls.sh /opt/gentls

# Add group and user for virtual mail
RUN groupadd -g 10000 vmail && useradd -m -d /vmail -u 10000 -g 10000 -s /sbin/nologin vmail

# Configure the software
ADD config/supervisor/supervisord.conf /etc/supervisord.conf
ADD config/postfix /etc/postfix/

RUN /opt/config-apply /etc/postfix/main.cf \
 && /opt/config-apply /etc/postfix/vhosts \
 && /opt/config-apply /etc/postfix/vmaps \
 && postmap /etc/postfix/vmaps \
 && /opt/gentls

# Start our init system
#CMD ['/sbin/dumb-init', '/usr/bin/supervisord -c /etc/supervisord.conf']
