#!/bin/bash
echo "This script should always run as root"
# Change hostname (not really needed)
hostname heroVPS
hostnamectl set-hostname heroVPS
# Update the package list and install latest updates
apt update
DEBIAN_FRONTEND=noninteractive apt upgrade -yq
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
echo "Done! :)"
echo "If you like this script feel free to contribute or donate at https://ko-fi.com/superhero1"
