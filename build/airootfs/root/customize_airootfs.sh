#!/bin/bash

set -e -u

#cp /run/archiso/bootmnt/arch/boot/x86_64/vmlinuz /boot/vmlinuz-linux

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

ln -sf /usr/share/zoneinfo/UTC /etc/localtime

usermod -s /usr/bin/zsh root
cp -aT /etc/skel/ /root/
chmod 700 /root
chmod 755 /usr

id -u liveuser &>/dev/null || useradd -m "liveuser" -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel"
passwd -d liveuser
echo 'created user'

chmod 750 /etc/sudoers.d
chmod 440 /etc/sudoers.d/g_wheel
chown -R root /etc/sudoers.d
echo 'sudoed'
EDITOR=nano
/etc/apricity-assets/Elegant_Dark/install.sh

sed -i.bak 's/Arch Linux/Apricity OS/g' /usr/lib/os-release
sed -i.bak 's/arch/apricity/g' /usr/lib/os-release
sed -i.bak 's/www.archlinux.org/www.apricityos.com/g' /usr/lib/os-release
sed -i.bak 's/bbs.archlinux.org/www.apricityos.com/g' /usr/lib/os-release
sed -i.bak 's/bugs.archlinux.org/www.apricityos.com/g' /usr/lib/os-release
cp /usr/lib/os-release /etc/os-release
#gpg --recv-keys 1EB2638FF56C0C53
arch=`uname -m`

if [ "$arch" == "x86_64" ]
then
	sed -i 's/Manjaro/Apricity OS/g' /etc/default/grub
	echo "x86_64, plymouth okay"
	echo "$(cat /etc/mkinitcpio.conf)"
	sed -i.bak 's/base udev/base udev plymouth/g' /etc/mkinitcpio.conf
	chown -R root.root /usr/share/plymouth/themes/apricity
	plymouth-set-default-theme -R apricity
	mkinitcpio -p linux
	systemctl enable org.cups.cupsd.service
	systemctl enable smbd nmbd
	sed -i "s/#Server/Server/g" /etc/pacman.d/mirrorlist
	sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
	echo 'seded'
	systemctl enable graphical.target gdm.service pacman-init.service dhcpcd.service
	echo 'enabled dhcpd, gdm'
	systemctl enable bluetooth.service
	echo 'enabled bluetooth'
	systemctl enable avahi-daemon.service
	echo 'enabled avahi'
	systemctl -fq enable NetworkManager ModemManager
	echo 'enabled network'
	systemctl mask systemd-rfkill@.service
	systemctl set-default graphical.target
	touch /etc/pacman.d/antergos-mirrorlist
	ln -fs /usr/share/applications/calamares.desktop /home/liveuser/.config/autostart/calamares.desktop
	chown -R root /etc/apricity-assets
	chmod -R 755 /etc/apricity-assets
	chmod 755 /usr/share
	chmod 755 /usr/share/applications
	chmod 755 /usr/lib
	chmod 755 /etc
else
	echo "i686, no plymouth"
fi
