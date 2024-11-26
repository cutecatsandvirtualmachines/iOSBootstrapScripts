#!/bin/bash

sudo apt update
sudo apt install -y build-essential meson ninja-build pkg-config \
                diffutils
                python3 python3-venv  \
                libglib2.0-dev libusb-1.0-0-dev libncursesw5-dev \
                libpixman-1-dev libepoxy-dev libv4l-dev libpng-dev \
                libsdl2-dev libsdl2-image-dev libgtk-3-dev libgdk-pixbuf2.0-dev \
                libasound2-dev libpulse-dev \
                libx11-dev git python3 unzip
				
#Download your ipsw from https://ipsw.me/

ipswname=$1

# If the parameter doesn't exist, set a default value
if [ -z "$ipswname" ]; then
  ipswname='./iPhone11,8,iPhone12,1_14.0_18A5351d_Restore.ipsw'
  curl -LO https://updates.cdn-apple.com/2020SummerSeed/fullrestores/001-35886/5FE9BE2E-17F8-41C8-96BB-B76E2B225888/iPhone11,8,iPhone12,1_14.0_18A5351d_Restore.ipsw
  unzip ./iPhone11,8,iPhone12,1_14.0_18A5351d_Restore.ipsw
  mv ./iPhone11,8,iPhone12,1_14.0_18A5351d_Restore/ ./iosemu/
fi

./qemubuild.sh

mkdir companion
mkdir iosemu

curl -LO https://releases.ubuntu.com/jammy/ubuntu-22.04.5-desktop-amd64.iso


cd iosemu
git clone https://github.com/TrungNguyen1909/qemu-t8030-tools.git
python3 qemu-t8030-tools/bootstrap_scripts/create_apticket.py n104ap BuildManifest.plist qemu-t8030-tools/bootstrap_scripts/ticket.shsh2 root_ticket.der

sshpass -p '132435' scp -o StrictHostKeyChecking=no ./root_ticket.der username@10.0.2.15:~
sshpass -p '132435' scp -o StrictHostKeyChecking=no $ipswname username@10.0.2.15:~