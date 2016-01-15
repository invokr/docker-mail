FROM centos:7
MAINTAINER Robin Dietrich

ENV POSTFIX_HOSTNAME mail.domain.tld
ENV POSTFIX_DOMAIN domain.tld
ENV POSTFIX_DESTINATION ""

# Install postfix, dovecot, and supervisor
RUN yum update -y && yum install -y cyrus-sasl dovecot postfix python-setuptools && \
    easy_install pip && pip install supervisor mako && yum clean all

# Install scripts
ADD scripts/dumb-init /sbin/dumb-init
ADD scripts/postfix.sh /opt/postfix
ADD scripts/config-apply.py /opt/config-apply

# Configure the software
ADD config/supervisor/supervisord.conf /etc/supervisord.conf
ADD config/postfix/main.cf /etc/postfix/main.cf
ADD config/postfix/master.cf /etc/postfix/master.cf

RUN /opt/config-apply /etc/postfix/main.cf

# Start our init system
#CMD ['/sbin/dumb-init', '/usr/bin/supervisord -c /etc/supervisord.conf']
