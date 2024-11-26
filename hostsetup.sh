#!/bin/bash

sudo apt update
sudo apt install -y build-essential meson ninja-build pkg-config \
                diffutils \
                python3 python3-venv  \
                libglib2.0-dev libusb-1.0-0-dev libncursesw5-dev \
                libpixman-1-dev libepoxy-dev libv4l-dev libpng-dev \
                libsdl2-dev libsdl2-image-dev libgtk-3-dev libgdk-pixbuf2.0-dev \
                libasound2-dev libpulse-dev \
                libx11-dev git python3 unzip qemu-kvm libvirt-daemon-system libvirt-clients virt-manager
				
#Download your ipsw from https://ipsw.me/

ipswname=$1

# If the parameter doesn't exist, set a default value
if [ -z "$ipswname" ]; then
  ipswname='$(pwd)/iPhone11,8,iPhone12,1_14.0_18A5351d_Restore.ipsw'
  curl -LO https://updates.cdn-apple.com/2020SummerSeed/fullrestores/001-35886/5FE9BE2E-17F8-41C8-96BB-B76E2B225888/iPhone11,8,iPhone12,1_14.0_18A5351d_Restore.ipsw
  unzip $(pwd)/iPhone11,8,iPhone12,1_14.0_18A5351d_Restore.ipsw
  mv $(pwd)/iPhone11,8,iPhone12,1_14.0_18A5351d_Restore/ $(pwd)/iosemu/
fi

$(pwd)/qemubuild.sh

mkdir companion
mkdir iosemu

if [[ -e "ubuntu-22.04.5-desktop-amd64.iso" ]]; then
    echo "The file 'ubuntu-22.04.5-desktop-amd64.iso' already exists."
else
	curl -LO https://releases.ubuntu.com/jammy/ubuntu-22.04.5-desktop-amd64.iso
fi

#First installation for the companion
$(pwd)/QEMUAppleSilicon/build/qemu-img create -f qcow2 ubuntu-vm.qcow2 40G
$(pwd)/QEMUAppleSilicon/build/qemu-system-x86_64 -m 2048 -cpu qemu64 -smp 2 -cdrom ubuntu-22.04.5-desktop-amd64.iso -drive file=ubuntu-vm.qcow2 -boot d -vga virtio -display default,show-cursor=on -usb -device usb-tablet -device usb-ehci,id=ehci -device usb-tcp-remote,bus=ehci.0

#First normal boot
gnome-terminal -- bash -c "$(pwd)/QEMUAppleSilicon/build/qemu-system-x86_64 -m 2048 -cpu qemu64 -smp 2 -drive file=ubuntu-vm.qcow2 -boot d -vga virtio -display default,show-cursor=on -usb -device usb-tablet -device usb-ehci,id=ehci -device usb-tcp-remote,bus=ehci.0; exec bash"

cd iosemu
git clone https://github.com/TrungNguyen1909/qemu-t8030-tools.git
python3 qemu-t8030-tools/bootstrap_scripts/create_apticket.py n104ap BuildManifest.plist qemu-t8030-tools/bootstrap_scripts/ticket.shsh2 root_ticket.der
