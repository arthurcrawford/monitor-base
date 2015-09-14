# Based on official centos 6
FROM centos:centos6
MAINTAINER Arthur 
# Install some common prerequisites
RUN yum install -y wget
RUN yum install -y epel-release
RUN yum install -y expect
RUN yum install -y httpd 
ENV TERM xterm
EXPOSE 80
# Add icinga2 repositories to yum config
RUN rpm --import http://packages.icinga.org/icinga.key
RUN wget http://packages.icinga.org/epel/ICINGA-release.repo -O /etc/yum.repos.d/ICINGA-release.repo
RUN yum makecache
# install icinga2
RUN yum install -y icinga2
RUN yum install -y nagios-plugins-all
RUN yum install -y mysql-server mysql
RUN yum install -y icinga2-ido-mysql
RUN yum install -y php php-cli php-pear php-xmlrpc php-xsl php-pdo php-soap php-gd php-ldap php-mysql
RUN yum install -y icingaweb2 icingacli
RUN yum install -y php-ZendFramework-Db-Adapter-Pdo-Mysql
# Icingaweb2 requires a default timezone set in php.ini
RUN sed -i "s/;date.timezone.*/date.timezone = Europe\/London/g" /etc/php.ini
# Setup mysql
COPY mysql_setup.sh mysql_setup.sh
COPY icinga_schema.sql icinga_schema.sql
COPY icingaweb2/mysql.schema.sql /usr/share/doc/icingaweb2/schema/mysql.schema.sql
# Setup python environment for 'supervisord'
RUN yum install -y python-pip
RUN pip install supervisor
RUN pip install 'meld3 == 1.0.1'
ENV PATH $PATH:/usr/lib/python2.6/site-packages/supervisor
COPY supervisord.conf /etc/supervisord.conf
# Run icinga2 service script once to correctly configure 
RUN service icinga2 start
CMD /usr/bin/supervisord
RUN icinga2 feature enable command
RUN usermod -a -G icingaweb2 apache
RUN icingacli setup config directory --group icingaweb2
# Set up mailx for using gmail smtp
RUN yum install -y mailx
RUN wget https://www.geotrust.com/resources/root_certificates/certificates/Equifax_Secure_Certificate_Authority.cer
RUN mkdir /etc/certs
RUN certutil -d /etc/certs -A -t TC -n "Equifax Secure Certificate Authority" -i Equifax_Secure_Certificate_Authority.cer
RUN chmod 755 /etc/certs/*
COPY mail.rc /etc/mail.rc
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
