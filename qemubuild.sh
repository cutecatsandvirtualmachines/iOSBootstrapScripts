#!/bin/bash

check_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unsupported"
    fi
}

os_type=$(check_os)

if [[ "$os_type" == "unsupported" ]]; then
    echo "Unsupported operating system. This script supports Linux and macOS only."
    exit 1
fi

if [[ "$os_type" == "linux" ]]; then
    sudo apt update
    sudo apt install -y build-essential meson ninja-build pkg-config \
                        diffutils \
                        python3 python3-venv \
                        libglib2.0-dev libusb-1.0-0-dev libncursesw5-dev \
                        libpixman-1-dev libepoxy-dev libv4l-dev libpng-dev \
                        libsdl2-dev libsdl2-image-dev libgtk-3-dev libgdk-pixbuf2.0-dev \
                        libasound2-dev libpulse-dev \
                        libx11-dev git
elif [[ "$os_type" == "macos" ]]; then
    # Check for Homebrew and install it if not present
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew update
    brew install meson ninja pkg-config \
                python3 glib libusb ncurses \
                pixman libepoxy libtasn1 libpng \
                sdl2 sdl2_image gtk+3 gdk-pixbuf \
                libx11 git \
                jtool2 jq coreutils gnutls libgcrypt
fi

# Clone the QEMUAppleSilicon repository
if [[ ! -d "QEMUAppleSilicon" ]]; then
    git clone https://github.com/ChefKissInc/QEMUAppleSilicon.git
fi

cd QEMUAppleSilicon

# Initialize and update submodules
if [[ ! -d ".git/modules" ]]; then
    git submodule update --init --recursive
fi

		
mkdir build
cd build		
../configure --enable-lzfse --disable-werror --enable-debug #Optional for debugging
make