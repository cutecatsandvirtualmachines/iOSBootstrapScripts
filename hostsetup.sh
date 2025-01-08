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
                        libx11-dev git python3 unzip qemu-kvm libvirt-daemon-system libvirt-clients virt-manager
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
                jtool2 jq coreutils libgcrypt
fi
				
#Download your ipsw from https://ipsw.me/
mkdir iosemu
mkdir companion

ipswname=$1

# If the parameter doesn't exist, set a default value
if [ -z "$ipswname" ]; then
  cd iosemu
  ipswname='$(pwd)/iPhone11,8,iPhone12,1_14.0_18A5351d_Restore.ipsw'
  curl -LO https://updates.cdn-apple.com/2020SummerSeed/fullrestores/001-35886/5FE9BE2E-17F8-41C8-96BB-B76E2B225888/iPhone11,8,iPhone12,1_14.0_18A5351d_Restore.ipsw
  unzip $(pwd)/iPhone11,8,iPhone12,1_14.0_18A5351d_Restore.ipsw
  cd ..
fi

chmod 777 ./qemubuild.sh
$(pwd)/qemubuild.sh

if [[ -e "ubuntu-22.04.5-desktop-amd64.iso" ]]; then
    echo "The file 'ubuntu-22.04.5-desktop-amd64.iso' already exists."
else
  cd companion
	curl -LO https://releases.ubuntu.com/jammy/ubuntu-22.04.5-desktop-amd64.iso
  cd ..
fi

#First installation for the companion
$(pwd)/QEMUAppleSilicon/build/qemu-img create -f qcow2 ubuntu-vm.qcow2 40G
$(pwd)/QEMUAppleSilicon/build/qemu-system-x86_64 -m 2048 -cpu qemu64 -smp 2 -cdrom ubuntu-22.04.5-desktop-amd64.iso -drive file=ubuntu-vm.qcow2 -boot d -vga virtio -display default,show-cursor=on -usb -device usb-tablet -device usb-ehci,id=ehci -device usb-tcp-remote,bus=ehci.0

#First normal boot
if [[ "$os_type" == "linux" ]]; then
    gnome-terminal -- bash -c "$(pwd)/QEMUAppleSilicon/build/qemu-system-x86_64 -m 2048 -cpu qemu64 -smp 2 -drive file=ubuntu-vm.qcow2 -boot d -vga virtio -display default,show-cursor=on -usb -device usb-tablet -device usb-ehci,id=ehci -device usb-tcp-remote,bus=ehci.0; exec bash"
elif [[ "$os_type" == "macos" ]]; then
    open -a Terminal "$(pwd)/QEMUAppleSilicon/build/qemu-system-x86_64 -m 2048 -cpu qemu64 -smp 2 -drive file=ubuntu-vm.qcow2 -boot d -vga virtio -display default,show-cursor=on -usb -device usb-tablet -device usb-ehci,id=ehci -device usb-tcp-remote,bus=ehci.0"
fi

cd iosemu
if [[ ! -d "qemu-t8030-tools" ]]; then
    git clone https://github.com/TrungNguyen1909/qemu-t8030-tools.git
fi

python3 -m venv ./
source ./bin/activate
python3 -m pip install pyasn1

python3 qemu-t8030-tools/bootstrap_scripts/create_apticket.py n104ap BuildManifest.plist qemu-t8030-tools/bootstrap_scripts/ticket.shsh2 root_ticket.der
