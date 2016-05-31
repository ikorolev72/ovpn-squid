#						squid+openvpn


##  What is it?
##  -----------
Script for start squid over openvpn connection, check and restart connection


##  The Latest Version
##------------------
	version 1.1 2016.02.06

##  Documentation
##  -------------


### 1. Installation

Install last version packages openvpn and squid
```

$ sudo aptitude update
$ sudo aptitude install openvpn  squid
$ dpkg -l|grep vpn
ii  openvpn                          2.3.2-7ubuntu3.1                 amd64        virtual private network daemon
$ dpkg -l|grep squid
ii  squid                            3.3.8-1ubuntu6.4                 amd64        dependency package from squid to squid3
ii  squid-langpack                   20121005-1                       all          Localized error pages for Squid
ii  squid3                           3.3.8-1ubuntu6.4                 amd64        Full featured Web Proxy cache (HTTP proxy)
ii  squid3-common                    3.3.8-1ubuntu6.4                 all          Full featured Web Proxy cache (HTTP proxy) - common files
```

extract tar archive in to /opt directory
```
$ cd /opt
$ sudo tar xvf /path_to_tar_file/mysquid.tar
$ ls -la /opt/mysquid
total 40
drwxr-xr-x 5 root root 4096 Feb  4 08:29 .
drwxr-xr-x 4 root root 4096 Feb  3 13:09 ..
-r-------- 1 root root   20 Jan 29 19:59 auth.txt
-rwxr-xr-x 1 root root  918 Feb  3 13:29 common-env-squid-vpn.sh
drwxr-xr-x 2 root root 4096 Feb  3 11:08 ovpn
-rwxr-xr-x 1 root root  634 Feb  3 13:31 route-permanent.sh
-rwxr-xr-x 1 root root 3155 Feb  4 07:41 start-vpn.sh
drwxr-xr-x 3 root root 4096 Feb  4 08:29 var
-rwxr-xr-x 1 root root 2066 Feb  4 07:45 watchdog.sh
```

# What you need to do before start
* Change the login/password of your OpenVPN provider in file `/opt/mysquid/auth.txt`
* Change variable `MY_NETWORK` to your networks and hosts in `common-env-squid-vpn.sh` . 
	Only hosts and networks in this variable will get access to squid.
* Put openvpn configs (files with .ovpn extention) into directory `/opt/mysquid/ovpn`. File names must not have spaces.
* Put files crl.pem and ca.crt into directory `/opt/mysquid/ovpn`	
* If you need you can change squid config template file `/opt/mysquid/var/squid.conf.template`
	( See section 'How to impruve squid security and performance' bellow ).


### 2. Administration manual

There are two main scripts:
```
$ ./start-vpn.sh
Usage: ./start-vpn.sh { [ start  config.ovpn ] | stop | help }
preffered 
$ sudo ./start-vpn.sh start USA_NY.ovpn 
``` 
give you opportunity to manualy start or stop squid with preffered vpn connection.


```
./watchdog.sh
Watchdog for checking vpn connection
Usage: ./watchdog.sh { start | stop | help }
$ sudo ./watchdog.sh start >/dev/null 2>&1 &
```
automaticly start squid with vpn connection and check ( use ping from vpn interface command ) tunnel. 
	In case someting wrong with tunnel, then watchdog restart squid with next in configs list vpn 
	connection.	Properly run this script as a daemon ( in background and without any output ) like 
	show above .

If you will stop squid and vpn connection, please, stop watchdog before.
```
$ sudo ./watchdog.sh stop
$ sudo ./start-vpn.sh stop
```

One more script `route-permanent.sh`
It add permanent routing to your networks and hosts (variable MY_NETWORK in `common-env-squid-vpn.sh`) and 
	fix bug with many permanent routes from openvpn. 
	Be carefull if you manualy add permanent route to hosts - please describe your hosts in MY_NETWORK 
	variable. But you can manualy add the route to any networks without any restrictions.

Log file of working scripts is `/opt/mysquid/var/log/check-vpn.log`



### 3. How to impruve squid security and performance

For change squid settings rules you need make change in template squid config file `/opt/mysquid/var/squid.conf.template`
	Now this file have settings for anonymouse proxy.
	You can add or modify any rules according with squid configure guide (exclude strings with 'XXX-' '-XXX' keywords, please)

What are you can change in simple way:
```
######################################
cache_mem 256 MB # change the ram cache according with your free memory
######################################
maximum_object_size_in_memory 1024 KB # if you set this parameter bellow there will be cached more a little objects, and squid may be faster
######################################
#cache_dir ufs /var/spool/squid3 1024 16 256 # uncomment if you will use disk cache. You may do not use disk cache by security reason
######################################
#access_log none   # uncomment next lines if you do not like your logs save anywhere
#icap_log none
#cache_log none
######################################
#dns_nameservers 8.8.8.8 8.8.4.4 # uncomment and change dns servers to preffered if you do not will use dns of your server provider
```


##  Licensing
##  ---------
	GNU

##  Contacts
##  --------

     o korolev-ia [at] yandex.ru
     o http://www.unixpin.com















	