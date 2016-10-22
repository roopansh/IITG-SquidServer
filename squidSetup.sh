#!/bin/bash

CheckRoot(){
	if [ "$EUID" -ne "0" ];then
		echo "Please run as root"
		exit 1
	else
		return 0
	fi
}

CheckSquid(){
	if [ ! -f "/etc/squid/squid.conf" ];then
		echo
		echo "Squid not installed already."
		echo "Installing squid first."
		echo
		SquidInstall
			if [ "$?" -ne "0" ]; then
				echo "There were some errors installing squid"
				exit 1
			fi
	else
		echo "Squid Already installed."
		echo
	fi
	Backup
}

SquidInstall(){
	apt install squid
	if [ "$?" = "0" ]; then
		return 0
	else
		return 1
	fi
}

Backup(){
	if [ -f "/etc/squid/squid.conf" ];then
		echo "Creating a backup of original squid.conf file."
		mv /etc/squid/squid.conf /etc/squid/squid.conf.backup
		echo "Backup of earlier squid configuration can be found at /etc/squid/squid.conf.backup"
	fi
}

ConfigureSquid(){
	echo "Changing the directory to /etc/squid"
	cd /etc/squid/
	echo "auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwd
acl ncsa_users proxy_auth REQUIRED
http_access allow ncsa_users" > squid.conf
	echo
	echo "Enter your IIT-G proxy server (e.g. 202.141.80.24) : "
	read proxy
	echo
	echo "Enter your IIT-G proxy username : "
	read username
	echo
	echo "Enter your IIT-G proxy password(NOTE: password will be visible) : "
	read password
	#cache_peer 202.141.80.24 parent 3128 0 default no-query proxy-only login=username:password
	foo="cache_peer $proxy parent 3128 0 default no-query proxy-only login=$username:$password"
	echo $foo >> squid.conf
	echo "never_direct allow all
http_port 3128
cache_effective_user proxy
cache_effective_group proxy" >> squid.conf
	echo "squid.conf file set up"
	echo
	echo "Now please set up your proxy server authentication"
}

CreatePasswd(){
	cd /etc/squid/
	touch passwd
	echo
	echo "What do you want as the username of your proxy : "
	read proxyUN
	echo 
	echo "Setting up your proxy authentication. Please enter Password :- "
	htpasswd passwd "$proxyUN"
	echo "Authentication Set up"
}

SquidService(){
	echo "Starting squid Service. Please Wait ... might take a few seconds"
	service squid restart
	echo "Enjoy your 24 hour Proxy. :)"
	echo "Your proxy is the IP address of this pc and port is 3128"
}

CheckRoot
CheckSquid
Backup
ConfigureSquid
CreatePasswd
SquidService