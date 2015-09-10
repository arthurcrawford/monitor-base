#!/bin/bash
set -e
sed -i "s/set *smtp-auth-user.*/set smtp-auth-user=${SMTP_AUTH_USER}/g" /etc/mail.rc
sed -i "s/set *smtp-auth-password.*/set smtp-auth-password=${SMTP_AUTH_PASSWORD}/g" /etc/mail.rc
sed -i "s/.*icinga@localhost.*/  email = \"${ICINGA_ADMIN_EMAIL}\"/g" /etc/icinga2/conf.d/users.conf
cat /etc/mail.rc
exec "$@"
