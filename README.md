# monitor-base
Icinga2 monitoring stack built on CentOS 6.

This image is intended as a reference or starting point for building an icinga2 monitoring stack.  Icinga2 setup and configuration is tricky and it helps to have a working image to start from.

In a production environment it is most likely you would want to do additional work around improvements to security and factoring out of dependent processes such as the database back-end and web server into separate Docker images.

Features
--------

* **CentOS 6** - official base image
* **icinga2** - from official icinga repo
* **icingaweb2** - front end
* **mysql** - db back-end
* **apache** - web server
* **supervisord** - process coordination (icinga + apache + mysql) 
* **mailx** - mail relay through Google SMTP

Example usage
-------------

Pull the image to your Docker host.

    $ sudo docker pull arthurcrawford/monitorbase

The following is a typical `run` command that could be used to create a container from this image running an interactive `bash` shell.

```bash
  docker run \
    -e SMTP_AUTH_USER=my.email@gmail.com \
    -e SMTP_AUTH_PASSWORD=my_email_password \
    -e ICINGA_ADMIN_EMAIL=icinga_admin@acme.com \
    -ti \
    -p 9393:80 \
    -p 5665:5665 \
    arthurcrawford/monitor-base \
    bash
```

To kick things off inside the interactive shell, run the process coordinator `supervisord` as follows:

```bash
[root@22e910d8067a /]# supervisord &
[...]
2015-09-09 17:30:09,662 INFO spawned: 'mysql' with pid 127
2015-09-09 17:30:09,665 INFO spawned: 'http' with pid 128
2015-09-09 17:30:09,669 INFO spawned: 'icinga' with pid 129
[...]
```

This should start all the necessary sub-processes, including the `mysql` database, `apache` web server and the icinga server itself.

This example usage exposes web port `9393` on the Docker host for the web console at the URL `http://docker-host:9393/icingaweb2`.  The other port, 5665, is used by icinga for master-slave communications with other icinga instances.

Inspect the `mailx` configuration in the container to see how mail will be relayed.

```bash
[root@e9f2cccec2b9 /]# cat /etc/mail.rc

set smtp-use-starttls
set ssl-verify=ignore
set smtp-auth=login
set smtp=smtp://smtp.gmail.com:587
set from="monitor@example.com(Monitor)"
set smtp-auth-user=my.email@gmail.com    << your gmail SMTP login
set smtp-auth-password=my_email_password << your gmail SMTP password
set nss-config-dir=/etc/certs                       
```

The environment variables `SMTP_AUTH_USER` and `SMTP_AUTH_PASSWORD`, specified in the Docker run command, are patched into this file by the default Docker entry-point script `docker-entrypoint.sh`. 

The final environment variable `ICINGA_ADMIN_EMAIL` is used also by `docker-entrypoint.sh` to inject an email address for the icinga admin user.  If the icinga configuration results in notifications being sent to the user `icingaadmin` they will, therefore, be relayed to this email address.

```bash
[root@e9f2cccec2b9 /]# cat /etc/icinga2/conf.d/users.conf 

object User "icingaadmin" {
  import "generic-user"

  display_name = "Icinga 2 Admin"
  groups = [ "icingaadmins" ]

  email = "icinga_admin@acme.com"  << admin notification email 
}

object UserGroup "icingaadmins" {
  display_name = "Icinga 2 Admin Group"
}

``` 

Web Based Setup Wizard
----------------------
When you first access the web console URL, you will have to go through the web-based configuration "wizard".  *[I would like to have automated this but haven't figured out the best way yet]*

The following sequence should get you up and running with a basic set of out-of-the-box configuration.

Point browser at `http://docker-host:9393/icingaweb2/`

Click the link `web-based setup-wizard`.

```bash
[root@e9f2cccec2b9 /]# icingacli setup token create
The newly generated setup token is: 2f4483a14b3d87cc
```

Enter `2f4483a14b3d87cc` into the `Setup Token` field on the web page.

On the next page leave the `Monitoring` section checked.

Enter the following information into the subsequent wizard pages.

####Icinga Web 2

    [ Next ]

####Authentication

    Authentication Type: Database
	
    [ Next ]

####Preferences

    User Preference Storage Type: Database

    [ Next ]
 
####Database Resource 

```
Database Name: icinga_web2
Username: icinga_web2
Password: *****

[ Next ] 
```

####Authentication Backend

```
Backend Name: icingaweb2

[ Next ] 
```

####Administration

```
Username: admin
Password: password
Repeat Password: password

[ Next ] 
```

####Application Configuration

```
Logging Type: Syslog
Logging Level: Error
Application Prefix: icingaweb2

[ Next ] 
```

####Database Setup

```
Username: root
Password:          << empty

[ Next ] 
```

####First Review Page

```
[ Next ] 
```

####Icinga web 2 Intro Page

```
[ Next ] 
```

####Monitoring Backend

```
Backend Name: icinga
Backend Type: IDO

[ Next ] 
```

####Monitoring IDO Resource

```
Resource Name: icinga_ido
Database Type: MySQL
Host: localhost
Port: 3306
Database Name: icinga
Username: icinga
Password: icinga

[ Next ] 
```

####Monitoring Instance

```
Instance Name: icinga
Instance Type: Local Command File
Command File: /var/run/icinga2/cmd/icinga2.cmd

[ Next ] 
```

####Monitoring Security

```
Protected Custom Variables: *pw*,*pass*,community

[ Next ] 
```

####Final Review Page

```
[ Finish ] 
```

####Login to Icinga Web 2

```
Username: admin
Password: password

[ Login ] 
```


