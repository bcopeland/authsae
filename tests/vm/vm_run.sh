#!/bin/bash
# run tests inside a VM, for CI.

# kvm passthrough isn't available in circle ci
QEMU=${QEMU:-qemu-system-x86_64}

KERNEL=testing-vm-kernel
ROOTFS=testing-vm-rootfs.img

# download a VM kernel from some random location on the internet
# the rootfs fstab mounts /dev/local with 9p in /local.  It should
# have iw and so on installed.
if [ ! -f $KERNEL ]; then
    curl -L -O "https://github.com/bcopeland/testing-vm/releases/download/v1.0/$KERNEL"
fi
if [ ! -f $ROOTFS ]; then
    curl -L -O "https://github.com/bcopeland/testing-vm/releases/download/v1.0/$ROOTFS.xz"
    xz -d $ROOTFS.xz
fi

$QEMU \
  -kernel $KERNEL \
  -drive file=$ROOTFS,format=raw,if=virtio \
  -fsdev local,security_model=none,id=fsdev-local,path=../.. \
  -device virtio-9p-pci,id=fs-local,fsdev=fsdev-local,mount_tag=/dev/local \
  -serial mon:stdio -nographic -vga none \
  -append "root=/dev/vda console=ttyS0" | tee testout.log

./testout-to-junit.sh testout.log > results.xml
