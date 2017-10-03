FROM centos:7
MAINTAINER Robin Dietrich <me@invokr.org>

# Expose smtpd, submission and imaps
EXPOSE 25
EXPOSE 587
EXPOSE 993

# Environment variables
ENV POSTFIX_HOSTNAME="mail.domain.tld"

# Add scripts and config to /opt
ADD scripts /opt/bin
ADD config /opt/config

# - Install postfix, dovecot, and supervisor
# - Add group and user for virtual mail handling
# - Add directories for postfix and dovecot data
# - Link tld-update script
# - Remove yum cache
RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
 && yum update -y && yum upgrade -y && yum install -y cronie cyrus-sasl dovecot opendkim \
    opendmarc postfix python-setuptools pypolicyd-spf rsyslog wget && easy_install pip \
 && pip install supervisor mako && yum clean all \
 && groupadd -g 10000 vmail && useradd -m -d /vmail -u 10000 -g 10000 -s /sbin/nologin vmail && chmod 755 /vmail \
 && usermod -G vmail postfix && usermod -G vmail dovecot \
 && mkdir -p /secure/postfix && touch /secure/postfix/vmaps /secure/postfix/vhosts /secure/postfix/vuids /secure/postfix/vgids \
 && mkdir -p /secure/dovecot && touch /secure/dovecot/users /secure/dovecot/passwd \
 && ln -s /opt/bin/update-tld-names /etc/cron.weekly/ && /opt/bin/update-tld-names \
 && rm -rf /var/cache/yum

# Add configurations for all services
ADD config/supervisor/supervisord.conf /etc/supervisord.conf
ADD config/rsyslog/file.conf /etc/rsyslog.conf
ADD config/opendmarc/opendmarc.conf /etc/opendmarc.conf
ADD config/postfix /etc/postfix/
ADD config/dovecot /etc/dovecot

# Start our init system
CMD ["/opt/bin/dumb-init", "/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
