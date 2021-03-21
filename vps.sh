#!/bin/bash
#
# Install command:
# curl --proto '=https' --tlsv1.2 -sSf https://superhero1.com/vps.sh | bash
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
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
NOCOLOR="\033[0m"
export NEWT_COLORS='
    root=white,black
    border=black,lightgray
    window=lightgray,lightgray
    shadow=black,gray
    title=black,lightgray
    button=black,cyan
    actbutton=white,cyan
    compactbutton=black,lightgray
    checkbox=black,lightgray
    actcheckbox=lightgray,cyan
    entry=black,lightgray
    disentry=gray,lightgray
    label=black,lightgray
    listbox=black,lightgray
    actlistbox=black,cyan
    sellistbox=lightgray,black
    actsellistbox=lightgray,black
    textbox=black,lightgray
    acttextbox=black,cyan
    emptyscale=,gray
    fullscale=,cyan
    helpline=white,black
    roottext=lightgrey,black
'
echo -e "${YELLOW}                                    .      "
echo -e "                                  .cxo'    "
echo -e "              ....'',,,,,''...',:okOOOk:.  "
echo -e "         .';loxkkOOOOOOOOOOOOOOOOOOOOOOk,  "
echo -e "       .:dOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOc  "
echo -e "     .:kOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOc  "
echo -e "     'okOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO0O;  "
echo -e "    .:xOOOkdlllodkOOOOOOOOOOkxollloxOOOkdc."
echo -e "    cOOOd;.     ..';codddl:,..     .,oOO0d."
echo -e "   'xOOl.             ...            .:k0o."
echo -e "   ;OOkl:llllollooolllooooollllllolloodk0l."
echo -e "   :OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOc "
echo -e "  'xOOOOO0OOOOOOOOOOOOOOOOOOOOO0OOOO0OOOO: "
echo -e " .oOOOOOkl:,;:cldkOOOOOOOOOOkdlc:;,;lkOOO; "
echo -e " .xOOOOOc.       .,lkOOOOOo;.       .lOOk, "
echo -e " .d0OOOOkl::;;;::cldOOOOOOkdlc:;,',;lkOOk, "
echo -e "  ;kOOOOOOO0OO0OOOOOOOOOOOOOOOOOOOOOOOO0x' "
echo -e "   .lk0OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOd. "
echo -e "     .,clodddddddddddddddddddddxOOOOOOOOO: "
echo -e "                               .:kOOOOOO0d."
echo -e "                               .:kOOOOOO0x'"
echo -e " .ldddddooddoodddddddddddddddddxkOOOOOOOOo."
echo -e " .xOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO0kl. "
echo -e " 'x0OOOOOOOOOOOOOOOOOOOOOOOOOOOO0OOOOxl'   "
echo -e " .,:::::::::::::::::::::::::::::::;,..     ${NOCOLOR}"
echo
echo

valid(){
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] Command Completed${NOCOLOR}"
    else
        echo -e "${RED}[-] Command failed${NOCOLOR}"
    fi
}

progress(){
    while :;do for s in / - \\ \|; do printf "\r$s";sleep 0.2;done;done &
    $i # or do something else here
    kill $!; trap 'kill $!' SIGTERM
    echo done
}

root_check(){
    if [[ $EUDI -ne 0 ]]; then
        echo -e "${RED}[-] This script must be run as root${NOCOLOR}"
        exit 1
    fi
}

hostname() {
    while true; do
        read -p "$(echo -e "${GREEN}[+] Do you want to set the host information? ${NOCOLOR}") " yn
        case "$yn" in
	    [yY]*)
                read -p "$(echo -e "${GREEN}[+] Enter hostname: ${NOCOLOR}")" HOSTNAME
                while [ -z "${HOSTNAME}" ]; do 
	            read -p "$( echo -e "${RED}[-] Hostname was not set, please enter hostname: ${NOCOLOR}")" HOSTNAME
                done
                # Change hostname (not really needed)
                hostname "${HOSTNAME}"; valid
                hostnamectl set-hostname "${HOSTNAME}"; valid
		break
		;;
            [nN]*)
                echo -e "${RED}[-] No hostname configuration set ${NOCOLOR}"
		break
                ;;
	    *)
		echo -e "${RED}[-] Invalid response${NOCOLOR}"
	esac
done
}

packages() {
    # Update the package list and install latest updates
    echo -e "${GREEN}[+] Updating package lists...${NOCOLOR}"    
    apt-get update -qq > /dev/null
    echo -e "${GREEN}[+] Installing prerequisite packages...${NOCOLOR}"
    apt-get install -qq -y nmap golang python3-pip unzip jq ruby ruby-dev libjpeg62 > /dev/null
    # Add go bin to PATH variable
    echo "export PATH=$HOME/go/bin:$PATH" >> ~/.bashrc
    cmd=(whiptail --title "Install Packages: " --checklist "Choose:" 20 78 15)
    options=(1 "ffuf" off    # any option can be set to default to "on"
             2 "wpscan" off
             3 "john" off
             4 "hydra" off
             5 "nikto" off
             6 "steghide" off	
	     7 "sqlmap" off
	     8 "stegseek" off)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    for choice in $choices;
    do
        case $choice in
	    1)
                echo "Installing ffuf"
		go get -u github.com/ffuf/ffuf > /dev/null
                ;;
            2)
                echo "Installing wpscan"
		gem install wpscan > /dev/null
                wpscan --no-banner --update > /dev/null
                ;;
            3)
                echo "Installing john"
		apt-get install -qq -y john > /dev/null 
                ;;
            4)
                echo "Installing hydra"
		apt-get install -qq -y hydra-gtk > /dev/null
                ;;
            5) 
                echo "Installing nikto"
		apt-get install -qq -y nikto > /dev/null
		;;
            6)
                echo "Installing steghide"
		apt-get install -qq -y steghide > /dev/null
		;;
            7)
                echo "Installing sqlmap"
		pip3 install sqlmap > /dev/null
		;;
            8)
                echo "Installing stegseek"
		wget -q $(curl -sL https://api.github.com/repos/RickdeJager/stegseek/releases/latest | jq -r '.assets[].browser_download_url') -O stegseek.deb && dpkg -i stegseek.deb > /dev/null && rm stegseek.deb
		;;
        esac
    done; valid
}

added() {    
    # Install additional resources
    echo -e "${GREEN}[+] Install additional resources${NOCOLOR}"
    echo
    cmd=(whiptail --title "Additional Resources: " --checklist "Choose:" 20 78 15)
    options=(1 "SecList Wordlist" off    # any option can be set to default to "on"
             2 "RockYou Wordlist" off
             3 "Nmap static" off
             4 "unzip static" off
	     5 "chisel static" off
	     6 "netcat static" off
	     7 "socat static" off
	     8 "wget static" off
             9 "Pentest PHP shell" off
	     10 "HTTP server w/upload" off)
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    echo -e "${GREEN}[+] Preparing for static binaries${NOCOLOR}"
    echo
    mkdir -p ~/web/static
    # Install useful scripts
    echo -e "${GREEN}[+] Preparing to grab useful scripts${NOCOLOR}"
    echo
    for choice in $choices
    do
        case $choice in
            1)
                wget -q https://github.com/danielmiessler/SecLists/archive/master.zip -O SecList.zip && unzip -qqo SecList.zip > /dev/null
                rm -f SecList.zip
                mkdir /usr/share/seclists/
    		mv SecLists-master/ /usr/share/seclists/
                ;;
            2)  
                wget -q https://github.com/danielmiessler/SecLists/archive/master.zip -O SecList.zip && unzip -qqo SecList.zip > /dev/null
                rm -f SecList.zip
                mv SecLists-master/ /usr/share/seclists/
                ;;
            3)
                wget -q $(curl -sL https://api.github.com/repos/ernw/static-toolbox/releases/latest | jq -r '.assets[].browser_download_url' | grep "linux64" | sort -ur | head -n1) -O ~/web/static/nmap.zip
                ;;
            4)
                wget -q https://busybox.net/downloads/binaries/1.31.0-i686-uclibc/busybox_UNZIP -O ~/web/static/unzip && chmod +x ~/web/static/unzip
                ;;
            5)
                wget -q $(curl -sL https://api.github.com/repos/jpillora/chisel/releases/latest | jq -r '.assets[].browser_download_url' | grep "linux_amd64") -O ~/web/static/chisel.gz && gunzip ~/web/static/chisel.gz && chmod +x ~/web/static/chisel
	        ;;
	    6)
                wget -q https://busybox.net/downloads/binaries/1.31.0-i686-uclibc/busybox_NC -O ~/web/static/nc && chmod +x ~/web/static/nc
                ;;
            7)
                wget -q https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/socat -O ~/web/static/socat && chmod +x ~/web/static/socat
                ;;
            8)
                wget -q https://busybox.net/downloads/binaries/1.31.0-i686-uclibc/busybox_WGET -O ~/web/static/wget && chmod +x ~/web/static/wget
                ;;
            9)
                wget -q https://raw.githubusercontent.com/pentestmonkey/php-reverse-shell/master/php-reverse-shell.php -O ~/web/revshell.php
    # replace IP with our VPS IP
    sed -i 's,^\($ip[ ]*=\).*,\1\ \"'`curl -sL ipconfig.me`\"\;',g' ~/web/revshell.php
                ;;
            10)
                mkdir ~/scripts
                # SimpleHttpServerWithUpload.py
                wget -q https://gist.githubusercontent.com/smidgedy/1986e52bb33af829383eb858cb38775c/raw/3e6ccace73bbd9f1bb0a7a40ffeb456b096655f5/SimpleHTTPServerWithUpload.py -O ~/scripts/SimpleHTTPServerWithUpload.py
                ;;
        esac
    done; valid
}

main() {
    SECONDS=0
    while [[ $SECONDS -lt 5 ]] || [[ ! -z $LOCK ]]; do 
	    echo -e "${RED}[!] If no options is chosen in the next 5 seconds"
	    echo -e "${RED}[!] this script will automatically execute!"
	    read -t 6 -p "$(echo -e "${GREEN}[+] Do you want customise package selection? (Y/N) ${NOCOLOR}") " yn
        case "$yn" in
            [yY]*)
                LOCK="1"
                root_check
                hostname
                packages
                added
		echo -e "${GREEN}[+] Done! :)${NOCOLOR}"
                echo -e "${GREEN}To use go tools like ffuf please run: ${RED}source ~/.bashrc${NOCOLOR}"
                echo -e "${GREEN}To upgrade existing packages run (optional): ${RED}apt upgrade${NOCOLOR}"
                echo -e "${RED}If you like this script feel free to contribute or donate at https://ko-fi.com/superhero1${NOCOLOR}"
                # EOF
		SECONDS=0
                break
                ;;
            [nN]*)
                break
                ;;
        esac
    done 
    if [[ $SECONDS -gt 5 ]]; then
	sleep 2
        hostname heroVPS
        hostnamectl set-hostname heroVPS
        echo -e "${GREEN}Updating package lists...${NOCOLOR}"
        apt-get update -qq > /dev/null
        echo -e "${GREEN}Installing basic tools...${NOCOLOR}"
        echo
        apt-get install -qq -y golang python3-pip unzip nmap jq hydra-gtk john nikto ruby ruby-dev steghide libjpeg62 > /dev/null
        echo "export PATH=$HOME/go/bin:$PATH" >> ~/.bashrc
        go get -u github.com/ffuf/ffuf > /dev/null
        gem install wpscan > /dev/null
        wpscan --no-banner --update > /dev/null
        pip3 install sqlmap > /dev/null
        wget -q $(curl -sL https://api.github.com/repos/RickdeJager/stegseek/releases/latest | jq -r '.assets[].browser_download_url') -O stegseek.deb && dpkg -i stegseek.deb > /dev/null && rm stegseek.deb
        echo -e "${GREEN}Grabbing wordlists...${NOCOLOR}"
        wget -q https://github.com/danielmiessler/SecLists/archive/master.zip -O SecList.zip && unzip -qqo SecList.zip > /dev/null
        rm -f SecList.zip
        mv SecLists-master/ /usr/share/seclists/
        mkdir /usr/share/wordlists
        wget -q https://download.weakpass.com/wordlists/90/rockyou.txt.gz && gunzip rockyou.txt.gz && mv rockyou.txt /usr/share/wordlists/
        echo -e "${GREEN}Grabbing static binaries...${NOCOLOR}"
        mkdir -p ~/web/static
        wget -q $(curl -sL https://api.github.com/repos/ernw/static-toolbox/releases/latest | jq -r '.assets[].browser_download_url' | grep "linux64" | sort -ur | head -n1) -O ~/web/static/nmap.zip
        wget -q https://busybox.net/downloads/binaries/1.31.0-i686-uclibc/busybox_UNZIP -O ~/web/static/unzip && chmod +x ~/web/static/unzip
        wget -q $(curl -sL https://api.github.com/repos/jpillora/chisel/releases/latest | jq -r '.assets[].browser_download_url' | grep "linux_amd64") -O ~/web/static/chisel.gz && gunzip ~/web/static/chisel.gz && chmod +x ~/web/static/chisel
        wget -q https://busybox.net/downloads/binaries/1.31.0-i686-uclibc/busybox_NC -O ~/web/static/nc && chmod +x ~/web/static/nc
        wget -q https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/socat -O ~/web/static/socat && chmod +x ~/web/static/socat
        wget -q https://busybox.net/downloads/binaries/1.31.0-i686-uclibc/busybox_WGET -O ~/web/static/wget && chmod +x ~/web/static/wget
        wget -q https://raw.githubusercontent.com/pentestmonkey/php-reverse-shell/master/php-reverse-shell.php -O ~/web/revshell.php
        sed -i 's,^\($ip[ ]*=\).*,\1\ \"'`curl -sL ipconfig.me`\"\;',g' ~/web/revshell.php
        echo -e "${GREEN}Grabbing useful scripts...${NOCOLOR}"
        mkdir ~/scripts
        wget -q https://gist.githubusercontent.com/smidgedy/1986e52bb33af829383eb858cb38775c/raw/3e6ccace73bbd9f1bb0a7a40ffeb456b096655f5/SimpleHTTPServerWithUpload.py -O ~/scripts/SimpleHTTPServerWithUpload.py
        echo -e "${GREEN}[+] Done! :)${NOCOLOR}"
        echo -e "${GREEN}To use go tools like ffuf please run: ${RED}source ~/.bashrc${NOCOLOR}"
        echo -e "${GREEN}To upgrade existing packages run (optional): ${RED}apt upgrade${NOCOLOR}"
        echo -e "${RED}If you like this script feel free to contribute or donate at https://ko-fi.com/superhero1${NOCOLOR}"
        # EOF
    fi
}

main
