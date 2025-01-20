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
    brew uninstall gnutls
    
    git clone https://github.com/lzfse/lzfse
    cd lzfse
    mkdir build; cd build
    cmake ..
    make
    sudo make install
    cd ../..

    brew install libtool automake autoconf autogen gtk-doc gmp
    brew install valgrind nodejs libfaketime lcov  expect softhsm
    brew install openssl socat net-tools util-linux
    brew install dash autoconf libtool gettext
    brew install automake libnettle nettle libunistring
    brew install libtasn1 libidn2 gawk gperf
    brew install bison gtk-doc cmake
    brew install texinfo texlive

    brew install libiconv libssh capstone nettle gnutls lzfse zstd

    echo 'export PATH="/opt/homebrew/opt/m4/bin:$PATH"' >> ~/.zshrc
fi

git clone https://github.com/ChefKissInc/QEMUAppleSilicon.git
cd QEMUAppleSilicon
git switch feat-sep_emu
git submodule update --init --recursive


mkdir -p "build"
cd "build"
CFLAGS="$CFLAGS -I/opt/homebrew/opt/lzfse/include/ -I/opt/homebrew/opt/gnutls/include/ -I/opt/homebrew/opt/nettle/include/ -I/opt/homebrew/opt/gmp/include/" LDFLAGS="$LDFLAGS -L/opt/homebrew/lib" LIBTOOL="glibtool" ../configure --target-list=aarch64-softmmu,x86_64-softmmu --enable-capstone --enable-curses --enable-libssh --enable-virtfs --enable-zstd --enable-lzfse --enable-gnutls --enable-nettle --enable-slirp --enable-hvf --disable-sdl --disable-gtk --enable-cocoa --disable-werror --extra-cflags="-DNCURSES_WIDECHAR=1"
make -j8