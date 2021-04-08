#!/bin/bash

w=$(echo $UID)
if [[ "$w" != "0" ]]; then
	echo -e "\e[31mROOT PERMISSIONS REQUIRED!\e[0m"
else
	#for crackmapexec
	python3 -m pip install pipx
	pipx ensurepath
	apt-get install python3-venv
	pipx install crackmapexec
	crackmapexec
	#for nfs
	apt install nfs-common
	#memcache
	apt install libmemcached-tools
fi
