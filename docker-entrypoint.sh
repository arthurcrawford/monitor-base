#!/bin/bash
set -e
sed -i "s/set *smtp-auth-user.*/set smtp-auth-user=${SMTP_AUTH_USER}/g" /etc/mail.rc
sed -i "s/set *smtp-auth-password.*/set smtp-auth-password=${SMTP_AUTH_PASSWORD}/g" /etc/mail.rc
sed -i "s/.*icinga@localhost.*/  email = \"${ICINGA_ADMIN_EMAIL}\"/g" /etc/icinga2/conf.d/users.conf

# Check for existing mysql data directory
if [ -e /var/lib/mysql/mysql ]
then
  # Use the existing directory 
  echo "Using existing mysql database files in /var/lib/mysql/"
else
  # Run the mysql database create scripts 
  echo "No mysql databases yet.  Running database scripts now..."
  service mysqld start
  ./mysql_setup.sh
  service mysqld stop
fi

exec "$@"
