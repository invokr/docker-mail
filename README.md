Docker Mailserver
=================

![](https://badge.imagelayers.io/invokr/mail:latest.svg)
![](https://img.shields.io/docker/pulls/invokr/mail.svg)

This container aims to provide a secure and portable mail environment based on Postfix and Dovecot.

SSL is enabled per default and new TLS keys are generated when starting the container,
these should be replaced with your own keys if possible.
Dovecot is only listening via SSL on port 993. Postfix is configured to use
opportunistic encryption as to not bounce mails from non-tls clients.
In addition to common spam lists, opendmarc is used to authenticate messages when
available. Mozillas public suffix list is updated once per week via cron.

Running the container
----------------------

    docker pull invokr/mail
    docker run -name mail -d -p 25:25 -p 587:587 -p 993:993 -v secure:/secure -v vmail:/vmail -e POSTFIX_HOSTNAME=mail.domain.tld invokr/mail

Make sure `POSTFIX_HOSTNAME` is a subdomain or else you won't be able to receive mail on that domain.

Stopping the container
----------------------

The container can be safely stopped with `docker stop mail`.

We are using [dumb-init](https://github.com/Yelp/dumb-init) to start `supervisord`
so that all of the daemons shut down gracefully.

Configuration
-------------

The configuration for the different services is kept in the `config` folder.
The following scripts are provided to quickly get your server up and running:

    # Create a new imap user, will ask for a password
    docker exec -it mail /opt/bin/useradd you@yourdomain.tld

    # Add a new alias
    docker exec mail /opt/bin/newalias you@yourdomain.tld alias@somedomain.tld

    # Accept mail for a new hostname
    docker exec mail /opt/bin/newdomain newdomain.tld

    # Remove a user (will ask for your confirmation)
    docker exec -it mail /opt/bin/userdel you@yourdomain.tld

Logs
----

All mail logs are written to `/secure/maillog` per default.

Backups
-------

All the data is saved in `/secure` (User configuration and SSL certificates) and
`/vmail` (Mailboxes). Backing up these directories is enough to transfer your mail
server to a new host or recover your data in the case of a hard drive failure.

License
-------

Public Domain or MIT, whatever is available in your country
