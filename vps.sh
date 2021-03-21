#!/bin/bash
#
# Install command:
# curl --proto '=https' --tlsv1.2 -sSf https://superhero1.com/vps.sh | sh
#
# MIT License
# 
# Copyright (c) 2021 superhero1 (Twitter: @_superhero1)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################################################################
RED="\033[1;31m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"
echo
echo -e "${RED}This script should always run as root${NOCOLOR}"
echo
# Change hostname (not really needed)
hostname heroVPS
hostnamectl set-hostname heroVPS
# Update the package list and install latest updates
echo -e "${GREEN}Updating package lists...${NOCOLOR}"
echo
apt-get update -qq > /dev/null
# Install additional packages we always need
# hydra, john, nikto etc
echo -e "${GREEN}Installing basic tools...${NOCOLOR}"
echo
apt-get install -qq -y golang python3-pip unzip nmap jq hydra-gtk john nikto ruby ruby-dev steghide libjpeg62 > /dev/null
# Add go bin to PATH variable
echo "export PATH=$HOME/go/bin:$PATH" >> ~/.bashrc
# Install single tools
# ffuf
go get -u github.com/ffuf/ffuf > /dev/null
# wpscan
gem install wpscan > /dev/null
wpscan --no-banner --update > /dev/null
# sqlmap
pip3 install sqlmap > /dev/null
# stegseek
wget -q $(curl -sL https://api.github.com/repos/RickdeJager/stegseek/releases/latest | jq -r '.assets[].browser_download_url') -O stegseek.deb && dpkg -i stegseek.deb > /dev/null && rm stegseek.deb
# Install additional resources
echo -e "${GREEN}Grabbing wordlists...${NOCOLOR}"
echo
# seclists to /usr/share/seclists
wget -q https://github.com/danielmiessler/SecLists/archive/master.zip -O SecList.zip && unzip -qqo SecList.zip
rm -f SecList.zip
mv SecLists-master/ /usr/share/seclists/
# Pull rockyou.txt to /usr/share/wordlists/
mkdir /usr/share/wordlists
wget -q https://download.weakpass.com/wordlists/90/rockyou.txt.gz && gunzip rockyou.txt.gz && mv rockyou.txt /usr/share/wordlists/
# Get some static binaries and put them into ~/web/static
echo -e "${GREEN}Grabbing static binaries...${NOCOLOR}"
echo
mkdir -p ~/web/static
# nmap
wget -q $(curl -sL https://api.github.com/repos/ernw/static-toolbox/releases/latest | jq -r '.assets[].browser_download_url' | grep "linux64" | sort -ur | head -n1) -O ~/web/static/nmap.zip
# unzip
wget -q https://busybox.net/downloads/binaries/1.31.0-i686-uclibc/busybox_UNZIP -O ~/web/static/unzip && chmod +x ~/web/static/unzip
# chisel
wget -q $(curl -sL https://api.github.com/repos/jpillora/chisel/releases/latest | jq -r '.assets[].browser_download_url' | grep "linux_amd64") -O ~/web/static/chisel.gz && gunzip ~/web/static/chisel.gz && chmod +x ~/web/static/chisel
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
# Install useful scripts
echo -e "${GREEN}Grabbing useful scripts...${NOCOLOR}"
echo
mkdir ~/scripts
# SimpleHttpServerWithUpload.py
wget https://gist.githubusercontent.com/smidgedy/1986e52bb33af829383eb858cb38775c/raw/3e6ccace73bbd9f1bb0a7a40ffeb456b096655f5/SimpleHTTPServerWithUpload.py -O ~/scripts/SimpleHTTPServerWithUpload.py
echo
echo
echo -e "${GREEN}Done! :)${NOCOLOR}"
echo
echo -e "To use go tools like ffuf please run: ${RED}source ~/bash.rc${NOCOLOR}"
echo
echo -e "To upgrade existing packages run (optional): ${RED}apt upgrade${NOCOLOR}"
echo
echo -e "${RED}If you like this script feel free to contribute or donate at https://ko-fi.com/superhero1${NOCOLOR}"
# EOF
