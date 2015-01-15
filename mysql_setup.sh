#!/bin/bash
service mysqld start
mysql -u root < icinga_schema.sql
mysql -u root icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql
mysql -u root icinga_web < /usr/share/icinga-web/etc/schema/mysql.sql
