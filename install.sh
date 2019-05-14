#!/bin/bash
# Created by didiatworkz
# timeTracker
#
# May 2019

_name=timeTracker

header() {
clear
cat << "EOF"
                            _
   ____                    | |
  / __ \__      _____  _ __| | __ ____
 / / _` \ \ /\ / / _ \| '__| |/ /|_  /
| | (_| |\ V  V / (_) | |  |   <  / /
 \ \__,_| \_/\_/ \___/|_|  |_|\_\/___|
  \____/                www.atworkz.de
EOF

echo
echo "$_name"
echo
echo
}
header

dpkg -s git &> /dev/null
if [ $? -ne 0 ]; then
    sudo apt update && sudo apt install git -y
fi

header
echo "Downloading files..."
git clone https://github.com/didiatworkz/$_name.git /tmp/$_name
cd /tmp/$_name

header
echo "Copy files to destination..."
sudo cp $_name.service /etc/systemd/system/$_name.service
sudo cp $_name.sh /usr/local/bin/$_name.sh

header
echo "Set system rights to files..."
sudo chown root /etc/systemd/system/$_name.service
sudo chown root /usr/local/bin/$_name.sh
sudo chmod +x /usr/local/bin/$_name.sh

header
echo "Start service..."
sudo systemctl daemon-reload
sudo systemctl enable $_name

header
echo "$_name successfuly installed"
sleep 5
exit
