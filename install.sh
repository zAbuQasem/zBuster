#!/bin/bash

w=$(echo $UID)
if [[ "$w" != "0" ]]; then
	echo -e "\e[31mROOT PERMISSIONS REQUIRED!\e[0m"
else
	wget https://golang.org/dl/go1.16.7.linux-amd64.tar.gz
	sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.16.7.linux-amd64.tar.gz
	mv go1.16.7.linux-amd64.tar.gz DElETE_ME/
	echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc
	echo 'export GOPATH=$HOME/go' >> $HOME/.zshrc
	echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bashrc
	echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.zshrc
	export GOPATH=$HOME/go
	export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
	GO111MODULE=on go get -u github.com/jaeles-project/gospider
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
