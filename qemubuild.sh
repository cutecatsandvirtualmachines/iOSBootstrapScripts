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
                libx11 git cmake \
                jtool2 jq coreutils libgcrypt autoconf
    brew uninstall gnutls
    
    git clone https://github.com/lzfse/lzfse
    cd lzfse
    mkdir build; cd build
    cmake ..
    make
    sudo make install
    cd ../..

    ######################## Building Nettle ########################
    # commit 40178e78ae73ec2a8cda8cd53664df9c73ac1961
    git clone https://gitlab.com/gnutls/nettle.git "./nettle"
    cd "./nettle"
    git checkout 40178e78ae73ec2a8cda8cd53664df9c73ac1961
    ./.bootstrap
    export CFLAGS=" -O2 -fno-stack-check -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk --target=arm64-apple-darwin"
    export LDFLAGS=" -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk -arch arm64"
    ./configure --enable-shared --enable-mini-gmp
    sudo make -j$(nproc)
    sudo make install
    cd -

    ######################## Building Gmp ########################
    curl -L https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz -o "./gmp-6.3.0.tar.xz"
    tar xf "./gmp-6.3.0.tar.xz" -C "."
    cd "./gmp-6.3.0"
    export CFLAGS=" -O2 -fno-stack-check -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk --target=arm64-apple-darwin"
    export LDFLAGS=" -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk -arch arm64"
    ./configure --enable-shared
    make -j$(nproc)
    sudo make install
    cd -

    ######################## Building libev ########################
    curl -L http://dist.schmorp.de/libev/Attic/libev-4.33.tar.gz -o "./libev-4.33.tar.gz"
    tar xf "./libev-4.33.tar.gz" -C "."
    cd "./libev-4.33"
    ./configure
    make -j$(nproc)
    sudo make install
    cd -

    ######################## Building Gnutls ########################
    brew install libtool automake autoconf autogen gtk-doc gmp
    brew install valgrind nodejs libfaketime lcov  expect softhsm
    brew install openssl socat net-tools util-linux
    brew install dash autoconf libtool gettext
    brew install automake libnettle nettle libunistring
    brew install libtasn1 libidn2 gawk gperf
    brew install bison gtk-doc
    brew install texinfo texlive

    echo 'export PATH="/opt/homebrew/opt/util-linux/bin:$PATH"' >> /Users/xliee/.zshrc
    echo 'export PATH="/opt/homebrew/opt/util-linux/sbin:$PATH"' >> /Users/xliee/.zshrc
    echo 'export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"' >> /Users/xliee/.zshrc
    echo 'export PKG_CONFIG_PATH="/opt/homebrew/opt/util-linux/lib/pkgconfig"' >> /Users/xliee/.zshrc

    echo 'export PATH="/opt/homebrew/opt/util-linux/bin:$PATH"' >> ~/.bash_profile
    echo 'export PATH="/opt/homebrew/opt/util-linux/sbin:$PATH"' >> ~/.bash_profile
    echo 'export PATH="/opt/homebrew/opt/gawk/libexec/gnubin:$PATH"' >> ~/.bash_profile
    echo 'export PKG_CONFIG_PATH="/opt/homebrew/opt/util-linux/lib/pkgconfig"' >> ~/.bash_profile

    export PATH="/opt/homebrew/opt/bison/bin:$PATH"

    export LDFLAGS="-L/opt/homebrew/opt/util-linux/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/util-linux/include"

    export LDFLAGS="$LDFLAGS -L/opt/homebrew/opt/bison/lib"

    # nettle
    # export LDFLAGS="$LDFLAGS -L/opt/homebrew/opt/nettle/lib"
    # export CPPFLAGS="$CPPFLAGS -I/opt/homebrew/opt/nettle/include"

    export LDFLAGS="$LDFLAGS -L/usr/local/lib"
    export CPPFLAGS="$CPPFLAGS -I/usr/local/include"
    export LDFLAGS="$LDFLAGS -L/opt/homebrew/lib"
    export CPPFLAGS="$CPPFLAGS -I/opt/homebrew/include"
    export LDFLAGS="$LDFLAGS -L/opt/local/lib"
    export CPPFLAGS="$CPPFLAGS -I/opt/local/include"

    git clone https://gitlab.com/gnutls/gnutls.git "./gnutls"
    cd "./gnutls"
    git submodule update --init --recursive
    ./bootstrap
    mkdir -p "./build"
    cd "./build"
    # ./configure --disable-doc --disable-guile --disable-nls --disable-tests --disable-tools --disable-valgrind-tests --with-included-libtasn1 --with-included-unistring --without-p11-kit --enable-local-libopts --enable-shared --with-included-libdane --with-included-libnettle --with-included-libunistring --with-included-libidn2 --with-included-libiconv --with-included-libunistring
    ../configure --disable-doc --disable-guile --disable-nls --disable-tests --disable-tools --disable-valgrind-tests --disable-openssl --without-p11-kit --enable-shared
    make -j$(nproc)
    sudo make install
    cd -

    echo 'export PATH="/opt/homebrew/opt/m4/bin:$PATH"' >> ~/.zshrc
fi

git clone https://github.com/ChefKissInc/QEMUAppleSilicon.git
cd QEMUAppleSilicon
git switch feat-sep_emu
git submodule update --init --recursive


brew install clib
clib install mikepb/endian.h
mkdir -p "build"
cd "build"
../configure --target-list=aarch64-softmmu,x86_64-softmmu --disable-capstone --enable-lzfse --enable-gnutls --enable-nettle --enable-slirp --enable-hvf --disable-werror --extra-cflags="-I/opt/local/include -I/usr/local/include"
sudo make -j$(nproc)