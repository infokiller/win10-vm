# Windows 10 VM

This repo contains notes about running a Windows 10 or Windows Server VM in
Linux (libvirt via QEMU/KVM) with good performance and with Secure Boot and
BitLocker enabled.

## Table of contents

- [Table of contents](#table-of-contents)
- [Status](#status)
- [Virtio](#virtio)
- [SPICE](#spice)
- [Secure Boot](#secure-boot)
  - [Using UEFI firmware with the required keys](#using-uefi-firmware-with-the-required-keys)
  - [Installing WHQL signed Virtio drivers](#installing-whql-signed-virtio-drivers)
  - [Installing the Virtio drivers in Windows](#installing-the-virtio-drivers-in-windows)
- [BitLocker](#bitlocker)
- [References](#references)

## Status

WIP: currently only covers setting up Secure Boot with [Virtio](#virtio) drivers
which are important for performance. See other guides in the
[references](#references) for additional performance improvements which will be
added to this repo after I will benchmark them.

## Virtio

Virtio is a virtualization technology focused on improving the performance of
emulated IO devices (storage and network). If you want to use Virtio in Secure
Boot, see the Secure Boot section. Otherwise, all you need is to:

- Download the
  [latest stable virtio-win iso](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)
  from Fedora.
- Mount the iso as a CDROM in virt-manager
- Run `virtio-win-guest-tools.exe` from the drive inside the VM

This will also install QXL display drivers and the SPICE agent.

## SPICE

[SPICE](https://www.spice-space.org/spice-user-manual.html) can improve graphics
performance in VMs (especially remote ones), and has other nice features like
host-guest clipboard syncing.

If you install Virtio using the method above, it should already contain the
essential components (possibly only the WebDAV daemon is not installed, I need
to verify this).

An (inferior) alternative is to download and install
[SPICE Windows guest tools](https://www.spice-space.org/download.html) (go to
"Windows binaries" in "Guest") from inside the VM. This will install all of the
SPICE components, and also outdated Virtio drivers.

Note that the
[Windows Guest tools repo](https://gitlab.freedesktop.org/spice/win32/spice-nsis)
is sometimes lagging. Another alternative is to install individual components
(QXL driver, SPICE agent, and the WebDAV daemon for folder sharing). See the
"Windows binaries" section in the
[SPICE downloads page](https://www.spice-space.org/download.html).

## Secure Boot

### Using UEFI firmware with the required keys

The UEFI firmware (OVMF in our case) must have the Microsoft keys enrolled in
order for it to boot Windows 10 in Secure Boot mode.

The OVMF package in Linux distros contain two files: one for the UEFI code (can
be named `OVMF.fd`, `OVMF_CODE.fd`, and `OVMF_CODE.secboot.fd`), and one for the
UEFI variables, usually named `OVMF_VARS.fd`.

To get Secure Boot working, you must use a `OVMF_VARS.fd` file that contains the
Microsoft keys. Options you have:

- Some Linux distros ship a `OVMF_VARS.fd` file that already contains the keys,
  so you can just use it. In Debian/Ubuntu the file is
  `/usr/share/OVMF/OVMF_VARS.ms.fd`. The [build.sh](./build.sh) script in will
  build an Ubuntu Docker container and copy the OVMF files to `./ovmf/out`.
- <https://github.com/rhuefi/qemu-ovmf-secureboot> can generate a file with the
  keys included
- You can enroll the keys manually in the UEFI firmware UI

### Installing WHQL signed Virtio drivers

The Virtio drivers
[available in Fedora](https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html#virtio-win-direct-downloads)
are not WHQL-signed (a Microsoft hardware certification program), which will
cause issues with Secure Boot
([reference](https://teams.microsoft.com/l/message/19:c0b91625615749b7bab11ca6cacb4784@thread.skype/1590069755600?tenantId=72f988bf-86f1-41af-91ab-2d7cd011db47&groupId=5e84b409-683b-44b3-af81-a2900a48b8a7&parentMessageId=1589810528154&teamName=Microsoft%20%E2%9D%A4%20Linux&channelName=Windows%20VM%20tips%2C%20tricks%2C%20and%20help&createdTime=1590069755600)).
Therefore, to use Virtio drivers (which is recommended for VM performance) and
Secure Boot (which is needed for security compliance), you must get WHQL-signed
drivers, which are only available in RHEL (RedHat Enterprise Linux) and CentOS.

The [build.sh](./build.sh) script automatically downloaded and verify the latest
available virtio-win package from CentOS, and extract the virtio-win.iso to `./virtio/out`.

You can also do this manually by downloading the rpm from
[the CentOS packages mirror](http://mirror.centos.org/centos/8-stream/AppStream/x86_64/os/Packages).
You will then need to extract the iso file from the rpm file and copy it to the
host. This can be done
[in multiple ways](https://stackoverflow.com/questions/18787375/how-do-i-extract-the-contents-of-an-rpm),
for example:

- `file-roller --extract-here virtio-win-*.rpm`
- `rpm2cpio virtio-win-*.rpm | cpio -idmv` (will definitely work inside the
  guest, may require installation in the host depending on the Linux
  distribution)

### Installing the Virtio drivers in Windows

Mount the iso file with the drivers in the Windows VM and use it to install them
(either
[individually](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_host_configuration_and_guest_installation_guide/form-virtualization_host_configuration_and_guest_installation_guide-para_virtualized_drivers-mounting_the_image_with_virt_manager)
or all of them by running `virtio-win-guest-tools.exe`). See
[this question](https://superuser.com/q/1057959) for converting an existing VM
to Virtio.

## BitLocker

In UEFI with Secure Boot enabled, you can set BitLocker to automatically unlock
using the TPM. In BIOS mode, you can add a small new virtual USB drive to the VM
and use it to automatically unlock BitLocker.

## References

- <https://github.com/ohthehugemanatee/win10vm>: libvirt config for a performant
  Windows 10 VM
- [Improve QEMU VM performance](https://wiki.archlinux.org/index.php/QEMU#Improve_virtual_machine_performance)
  section from the Arch wiki.
- [libvirt mailing list post](https://www.redhat.com/archives/libvir-list/2019-January/msg01004.html)
  with a great explanation on how UEFI works in QEMU and libvirt.
- [OpenStack docs](https://specs.openstack.org/openstack/nova-specs/specs/train/approved/allow-secure-boot-for-qemu-kvm-guests.html)
  on enabling Secure Boot in libvirt/QEMU with some useful information
  (especially the
  [low level section](https://specs.openstack.org/openstack/nova-specs/specs/train/approved/allow-secure-boot-for-qemu-kvm-guests.html#low-level-background-on-different-kinds-of-ovmf-builds)
  and
  [file paths](https://specs.openstack.org/openstack/nova-specs/specs/train/approved/allow-secure-boot-for-qemu-kvm-guests.html#ovmf-binary-files-and-variable-store-vars-file-paths)).
