#!/bin/sh
#For apt
#crackmapexec
sudo python3 -m pip install pipx
sudo pipx ensurepath
sudo apt-get install python3-venv
pipx install crackmapexec

#feroxbuster
curl -sLO https://github.com/epi052/feroxbuster/releases/latest/download/feroxbuster_amd64.deb.zip
unzip feroxbuster_amd64.deb.zip
sudo apt install ./feroxbuster_*_amd64.deb

#seclist
cd /usr/share
sudo wget -c https://github.com/danielmiessler/SecLists/archive/master.zip -O SecList.zip \
  && sudo unzip SecList.zip \
  && sudo rm -f SecList.zip
