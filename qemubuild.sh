#!/bin/bash

sudo apt update
sudo apt install -y build-essential meson ninja-build pkg-config \
                diffutils
                python3 python3-venv  \
                libglib2.0-dev libusb-1.0-0-dev libncursesw5-dev \
                libpixman-1-dev libepoxy-dev libv4l-dev libpng-dev \
                libsdl2-dev libsdl2-image-dev libgtk-3-dev libgdk-pixbuf2.0-dev \
                libasound2-dev libpulse-dev \
                libx11-dev git
				
git clone https://github.com/ChefKissInc/QEMUAppleSilicon.git
cd QEMUAppleSilicon
git submodule update --init --recursive
		
mkdir build
cd build		
../configure --enable-lzfse --disable-werror --enable-debug #Optional for debugging
make