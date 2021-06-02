#!/bin/bash

sudo apt-get remove docker docker-engine docker.io containerd runc -y >/dev/null

sudo apt-get update -y > /dev/null

sudo apt-get install -y > /dev/null \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
FILE=/usr/share/keyrings/docker-archive-keyring.gpg
if [ -f "$FILE" ]; then
    yes | rm -rf /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null
fi

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg  > /dev/null

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#echo \
#  "deb [arch=amd64] https://download.docker.com/linux/ubuntu artful stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y  > /dev/null
sudo apt-get install docker-ce docker-ce-cli containerd.io -y  > /dev/null

apt-cache madison docker-ce | sed 's/.*|\(.*\)|.*/\1/' > cache.txt
version=$(apt-cache madison docker-ce | sed 's/.*|\(.*\)|.*/\1/')
y=0
for i in $version; do
((y=y+1))
echo 'ID' $y' --- Available versions: ' $i
done
echo 'Which version do you want to install?'

read version_id
while [ $version_id -gt $y ] || [ $version_id -lt 0 ]; do
	echo 'Invalid ID, select one from 1 to ' $y
	read version_id
done
sed 's/^[ \t]*//' cache.txt > cache2.txt

install_version=$(awk '{if(NR=='$version_id') print $0}' cache2.txt)
echo 'Please wait a few second'
sudo apt-get install docker-ce=$install_version docker-ce-cli=$install_version containerd.io -y --allow-downgrades > /dev/null

rm cache.txt
rm cache2.txt

echo 'Done, your Docker version is changed to ' $install_version
