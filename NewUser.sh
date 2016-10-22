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
	if [ ! -d "/etc/squid/" ];then
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
}

SquidInstall(){
	apt install squid
	if [ "$?" = "0" ]; then
		return 0
	else
		return 1
	fi
}

CreatePasswd(){
	cd /etc/squid/
	if [ ! -d "/etc/squid/" ]; then
			echo "Please set up the squid service first"
			exit 1 
	fi
	echo
	echo "What do you want as the username of your proxy : "
	read proxyUN
	echo 
	echo "Setting up your proxy authentication. Please enter Password :- "
	htpasswd passwd "$proxyUN"
	if [ "$?" -ne "0" ]; then
		echo "There were some errors"
		exit 1
	fi
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
CreatePasswd
SquidService