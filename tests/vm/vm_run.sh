#!/bin/bash
# run tests inside a VM, for CI.

# download a VM kernel from some random location on the internet
# the rootfs fstab mounts /dev/local with 9p in /local.  It should
# have iw and so on installed.
if [ ! -f authsae-vm-kernel ]; then
    curl -O 'https://bobcopeland.com/srcs/authsae-vm-kernel'
fi
if [ ! -f authsae-vm.img ]; then
    curl -O 'https://bobcopeland.com/srcs/authsae-vm.img.xz'
    xz -d authsae-vm.img.xz
fi

# kvm isn't available in circle ci
QEMU=qemu-system-x86_64

$QEMU \
  -kernel authsae-vm-kernel \
  -drive file=authsae-vm.img,format=raw,if=virtio \
  -fsdev local,security_model=none,id=fsdev-local,path=../.. \
  -device virtio-9p-pci,id=fs-local,fsdev=fsdev-local,mount_tag=/dev/local \
  -serial mon:stdio -nographic -vga none \
  -append "root=/dev/vda console=ttyS0"
