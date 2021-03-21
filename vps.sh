#!/bin/bash
# Install command:
# curl --proto '=https' --tlsv1.2 -sSf https://superhero1.com/vps.sh | sh
RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"
echo
echo "This script should always run as root"
# Change hostname (not really needed)
hostname heroVPS
hostnamectl set-hostname heroVPS
# Update the package list and install latest updates
apt update
# Install additional packages we always need
# hydra, john, nikto etc
apt install -y golang python3-pip unzip nmap jq hydra-gtk john nikto ruby ruby-dev steghide libjpeg62
# Add go bin to PATH variable
echo "export PATH=$HOME/go/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
# Install single tools
# ffuf
go get -u github.com/ffuf/ffuf
# wpscan
gem install wpscan
wpscan --no-banner --update
# sqlmap
pip3 install sqlmap
# stegseek
wget -q $(curl -sL https://api.github.com/repos/RickdeJager/stegseek/releases/latest | jq -r '.assets[].browser_download_url') -O stegseek.deb && dpkg -i stegseek.deb && rm stegseek.deb
# Install additional resources
# seclists to /usr/share/seclists
wget -c https://github.com/danielmiessler/SecLists/archive/master.zip -O SecList.zip && unzip -o SecList.zip
rm -f SecList.zip
mv SecLists-master/ /usr/share/seclists/
# Pull rockyou.txt to /usr/share/wordlists/
mkdir /usr/share/wordlists
wget https://download.weakpass.com/wordlists/90/rockyou.txt.gz
gunzip rockyou.txt.gz && mv rockyou.txt /usr/share/wordlists/
# Get some static binaries and put them into ~/web/static
mkdir -p ~/web/static
# nmap
wget -q $(curl -sL https://api.github.com/repos/ernw/static-toolbox/releases/latest | jq -r '.assets[].browser_download_url' | grep "linux64" | sort -ur | head -n1) -O ~/web/static/nmap.zip
# unzip
wget -q https://busybox.net/downloads/binaries/1.31.0-i686-uclibc/busybox_UNZIP -O ~/web/static/unzip && chmod +x ~/web/static/unzip
# chisel
 wget -q $(curl -sL https://api.github.com/repos/jpillora/chisel/releases/latest | jq -r '.assets[].browser_download_url' | grep "linux_amd64") -O ~/web/static/chisel.gz && gunzip chisel.gz && chmod +x ~/web/static/chisel
# nc
wget -q https://busybox.net/downloads/binaries/1.31.0-i686-uclibc/busybox_NC -O ~/web/static/nc && chmod +x ~/web/static/nc
# socat
wget -q https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/socat -O ~/web/static/socat && chmod +x ~/web/static/socat
# wget
wget -q https://busybox.net/downloads/binaries/1.31.0-i686-uclibc/busybox_WGET -O ~/web/static/wget && chmod +x ~/web/static/wget
# get pentestmonkey php reverse shell
wget -q https://raw.githubusercontent.com/pentestmonkey/php-reverse-shell/master/php-reverse-shell.php -O ~/web/revshell.php
# replace IP with our VPS IP
sed -i 's,^\($ip[ ]*=\).*,\1\ \"'`curl -sL ipconfig.me`\"\;',g' ~/web/revshell.php
# SimpleHttpServerWithUpload.py
echo
echo
echo -e "${GREEN}Done! :)${NOCOLOR}"
echo
echo "If you like you can upgrade existing packages to their latest version running: apt upgrade"
echo
echo -e "${RED}If you like this script feel free to contribute or donate at https://ko-fi.com/superhero1${NOCOLOR}"