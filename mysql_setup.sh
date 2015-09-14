#!/bin/bash
mysql -u root < icinga_schema.sql
mysql -u root icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql
