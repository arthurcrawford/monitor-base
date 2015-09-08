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
# Add icinga2 repo config
RUN rpm --import http://packages.icinga.org/icinga.key
RUN wget http://packages.icinga.org/epel/ICINGA-release.repo -O /etc/yum.repos.d/ICINGA-release.repo
# Update yum
RUN yum makecache
# install icinga2
RUN yum install -y icinga2
RUN yum install -y nagios-plugins-all
RUN yum install -y mysql-server mysql
RUN yum install -y icinga2-ido-mysql
# Initialize mysql by running the service script actual daemon will be controlled by supervisor
RUN yum install -y php php-cli php-pear php-xmlrpc php-xsl php-pdo php-soap php-gd php-ldap php-mysql
RUN yum install -y icinga-web icinga-web-mysql icinga-web-module-pnp
RUN yum install -y icingaweb2 icingacli
RUN yum install -y php-ZendFramework-Db-Adapter-Pdo-Mysql
RUN sed -i "s/;date.timezone.*/date.timezone = Europe\/London/g" /etc/php.ini
RUN service mysqld start
COPY mysql_setup.sh mysql_setup.sh
COPY icinga_schema.sql icinga_schema.sql
COPY icingaweb2/mysql.schema.sql /usr/share/doc/icingaweb2/schema/mysql.schema.sql
RUN ./mysql_setup.sh
RUN yum install -y python-pip
RUN pip install supervisor
# Specific dependency of supervisor
RUN pip install 'meld3 == 1.0.1'
# Install Icinga2 web
# Add supervisor python shell scripts to PATH
ENV PATH $PATH:/usr/lib/python2.6/site-packages/supervisor
# Copy the supervisor config containing the icinca2 daemon command
COPY supervisord.conf /etc/supervisord.conf
# Run icinga2 service script once to correctly configure 
RUN service icinga2 start
CMD /usr/bin/supervisord
RUN icinga2 feature enable command
RUN usermod -a -G icingaweb2 apache
# Set up mailx for using gmail smtp
RUN wget https://www.geotrust.com/resources/root_certificates/certificates/Equifax_Secure_Certificate_Authority.cer
RUN mkdir /root/certs
RUN certutil -d /root/certs -A -t TC -n "Equifax Secure Certificate Authority" -i Equifax_Secure_Certificate_Authority.cer
COPY mail.rc /etc/mail.rc
