#!/bin/bash
[ `whoami` = root ] || { sudo "$0" "$@"; exit $?; }

if [ -z $2 ] ; then
	echo "ERROR: Missing parameters"
	echo "Script requires following format:"
	echo "script.sh [int http port] [int https port]"
	exit 0
fi

echo -n "Enter New Password for GSCMS: "
read -s password1
echo
echo -n "Re-Enter New Password for GSCMS: "
read -s password2
echo

while [ "$password1" != "$password2" ]; do
	echo "Passwords did not match.  Please try again."
	echo -n "Enter New Password for GSCMS: "
	read -s password1
	echo
	echo -n "Re-Enter New Password for GSCMS: "
	read -s password2
	echo
done

sudo echo "iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port $1" >> /etc/rc.local
sudo echo "iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j REDIRECT --to-port $2" >> /etc/rc.local
sudo apt-get update && sudo apt-get upgrade -y
# might need to give the thumbs up for grub
sudo apt-get install curl postgresql -y
curl --silent --location https://deb.nodesource.com/setup_5.x | sudo bash -
sudo apt-get install nodejs -y

if !(id -u "gscms" >/dev/null 2>&1); then
    sudo adduser --disabled-password --gecos "" gscms
fi

sudo su postgres -c "psql -c \"CREATE USER gscms WITH LOGIN PASSWORD '$password' CREATEDB\""
sudo su postgres -c "psql -c \"CREATE DATABASE gscms WITH OWNER gscms\""

# init db here

sudo su gscms -c "cd ~ && curl --silent --location https://github.com/Good-Sir-Creations/GSCMS/archive/master.zip >> master.zip && unzip master.zip && mv GSCMS-master GSCMS && rm master.zip && cd ~/GSCMS && npm i && touch .config.json && echo '{\"db\" : {\"username\": \"gscms\",\"password\": \"$password1\",\"http\":\"$1\",\"https\":\"$2\"}}' >> config.json"
sudo shutdown -r now