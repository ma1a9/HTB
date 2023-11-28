#!/bin/bash

apt update -y
wait
apt upgrade -y
wait

#Install guake
apt -y install guake
wait

#Install flameshot
apt -y install flameshot
wait

#Install jq
apt -y install jq
wait

#Install xclip
apt -y install xclip
wait

#Install rlwrap
apt -y install rlwrap
wait

#Install keeppassx
apt -y install keepassx
wait

#Install remmina
apt -y install remmina
wait

#Install seclists
apt -y install seclists
wait

#Install gobuster
apt -y install gobuster
wait

#Install linux-exploit-suggester
apt -y install linux-exploit-suggester
wait

#Install peass
apt -y install peass
wait

#Install nishang
apt -y install nishang
wait

#Install cifs-utils
apt -y install cifs-utils
wait

#Install feroxbuster
apt -y install feroxbuster
wait

#Install bloodhound
apt -y install bloodhound
wait

#Install sublimetext
apt-get install sublime-text
wait

#Install terminator
apt-get -y install terminator
wait


git clone https://github.com/obsidianmd/obsidian-releases/releases/download/v1.3.4/Obsidian-1.3.4-arm64.AppImage
#日本語環境
#・日本語表示
#・日本語入力
#
