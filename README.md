# monitor-base
Icinga2 monitoring stack built on CentOS 6.

Example usage
-------------

```bash
$ docker run -ti -p 9393:80 -p 5665:5665 mon bash

```

Exposes web port `9393` on localhost and icinga port 5665.

```bash
[root@e9f2cccec2b9 /]# vi /etc/mail.rc
```

Modify the config for `mailx` in /etc/mail.rc.  For example, the following uses the gmail SMTP service for relaying mail.

```bash
set smtp-use-starttls
set ssl-verify=ignore
set smtp-auth=login
set smtp=smtp://smtp.gmail.com:587
set from="monitor@example.com(Monitor)"
set smtp-auth-user=monitor@example.com << your gmail SMTP login
set smtp-auth-password=MyS3cur3P455w0rd! << your gmail SMTP password
set nss-config-dir=/etc/certs                       
```

```bash
[root@e9f2cccec2b9 /]# vi /etc/icinga2/conf.d/users.conf 
``` 

Modify the `icinga` users config file and add a real email address that will receive notifications through the SMTP relay.

```bash
object User "icingaadmin" {
  import "generic-user"

  display_name = "Icinga 2 Admin"
  groups = [ "icingaadmins" ]

  email = "icinga@localhost"  << target email for notifications
}

object UserGroup "icingaadmins" {
  display_name = "Icinga 2 Admin Group"
}

``` 

Run the process supervisor `supervisord`.

```bash
# supervisord &
[...]
2015-09-09 17:30:09,662 INFO spawned: 'mysql' with pid 127
2015-09-09 17:30:09,665 INFO spawned: 'http' with pid 128
2015-09-09 17:30:09,669 INFO spawned: 'icinga' with pid 129
[...]
```

This should start all the necessary processes, including the `mysql` database, `apache` web server and the icinga server itself.

Web Based Setup Wizard
----------------------

The following sequence should get you up and running with a basic set of out-of-the-box  configuration.

Point browser at `http://192.168.99.100:9393/icingaweb2/`

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


