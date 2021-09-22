#!/bin/bash
echo "[++]Installing Golang 1.16.7"
echo "[!]CTRL+C if you want to abort the installation"
sleep 6
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
sudo python3 -m pip install pipx
sudo pipx ensurepath
sudo apt-get install python3-venv
sudo pipx install crackmapexec
crackmapexec
#for nfs
sudo apt install nfs-common
#memcache
sudo apt install libmemcached-tools
