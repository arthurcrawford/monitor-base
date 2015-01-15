# Based on official centos 6
FROM centos:centos6
MAINTAINER Arthur 
# Install some common prerequisites
RUN yum install -y wget
RUN yum install -y epel-release
RUN yum install -y expect
RUN yum install -y httpd 
ENV TERM=xterm
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
RUN service mysqld start
COPY mysql_setup.sh mysql_setup.sh
COPY icinga_schema.sql icinga_schema.sql
RUN ./mysql_setup.sh
RUN yum install -y python-pip
RUN pip install supervisor
# Install Icinga2 web
# Add supervisor python shell scripts to PATH
ENV PATH=$PATH:/usr/lib/python2.6/site-packages/supervisor
# Copy the supervisor config containing the icinca2 daemon command
COPY supervisord.conf /etc/supervisord.conf
# Run icinga2 service script once to correctly configure 
RUN service icinga2 start
CMD /usr/bin/supervisord

