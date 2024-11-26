#!/bin/bash

sudo apt update
sudo apt update
sudo apt install -y build-essential meson ninja-build pkg-config \
                diffutils \
                python3 python3-venv  \
                libglib2.0-dev libusb-1.0-0-dev libncursesw5-dev \
                libpixman-1-dev libepoxy-dev libv4l-dev libpng-dev \
                libsdl2-dev libsdl2-image-dev libgtk-3-dev libgdk-pixbuf2.0-dev \
                libasound2-dev libpulse-dev \
                libx11-dev git libtool-bin libusb-1.0-0-dev libreadline-dev \
				automake openssh-server ssh curl libfdt-dev zlib1g-dev libtasn1-dev cmake libgnutls28-dev
			
#Download your ipsw from https://ipsw.me/

ipswname=$1

# If the parameter doesn't exist, set a default value
if [ -z "$ipswname" ]; then
  ipswname='~/iPhone11,8,iPhone12,1_14.0_18A5351d_Restore.ipsw'
  curl -LO https://updates.cdn-apple.com/2020SummerSeed/fullrestores/001-35886/5FE9BE2E-17F8-41C8-96BB-B76E2B225888/iPhone11,8,iPhone12,1_14.0_18A5351d_Restore.ipsw
  unzip ./iPhone11,8,iPhone12,1_14.0_18A5351d_Restore.ipsw
  mv ./iPhone11,8,iPhone12,1_14.0_18A5351d_Restore/ ./iosemu/
fi

#libplist			
git clone https://github.com/libimobiledevice/libplist.git
cd libplist
./autogen.sh
make
sudo make install
cd ..

#libimobiledevice-glue
git clone https://github.com/libimobiledevice/libimobiledevice-glue.git
cd libimobiledevice-glue
./autogen.sh
make
sudo make install
cd ..

#libirecovery
git clone https://github.com/libimobiledevice/libirecovery.git
cd libirecovery
./autogen.sh
make
sudo make install
cd ..

#libusbmuxd
git clone https://github.com/libimobiledevice/libusbmuxd.git
cd libusbmuxd
./autogen.sh
make
sudo make install
cd ..

#libtatsu
git clone https://github.com/libimobiledevice/libtatsu.git
cd libtatsu
./autogen.sh
make
sudo make install
cd ..

#usbmuxd
git clone https://github.com/libimobiledevice/usbmuxd.git
cd usbmuxd
./autogen.sh
make
sudo make install
cd ..

#usbmuxd
git clone https://github.com/libimobiledevice/usbmuxd.git
cd usbmuxd
./autogen.sh
make
sudo make install
cd ..

#idevicerestore custom fork for ios emulator
git clone https://github.com/cutecatsandvirtualmachines/idevicerestore.git
cd idevicerestore
./autogen.sh
make
sudo make install
cd ..
