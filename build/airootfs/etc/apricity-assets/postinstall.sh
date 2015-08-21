	# Fix transmission leftover
	if [ -f /usr/lib/tmpfiles.d/transmission.conf ]; then
		mv /usr/lib/tmpfiles.d/transmission.conf /usr/lib/tmpfiles.d/transmission.conf.backup
	fi

	# Set BROWSER var
	export _BROWSER=google-chrome-beta
	echo "BROWSER=/usr/bin/${_BROWSER}" >> /etc/environment
	echo "BROWSER=/usr/bin/${_BROWSER}" >> /etc/skel/.bashrc
	echo "BROWSER=/usr/bin/${_BROWSER}" >> /etc/profile

	# Set gsettings
	rm /usr/share/applications/bssh.desktop
	rm /usr/share/applications/bvnc.desktop
	rm /usr/share/applications/avahi-discover.desktop
	rm /usr/share/applications/qv4l2.desktop
	rm /usr/share/applications/polkit-gnome-authentication-agent-1.desktop
	rm /usr/share/applications/tracker-needle.desktop
	rm /usr/share/applications/gksu.desktop
	rm /usr/share/applications/gucharmap.desktop
	rm /usr/share/applications/cups.desktop
	rm /usr/share/applications/uxterm.desktop
	rm /usr/share/applications/sbackup-restore-su.desktop
	rm /usr/share/applications/sbackup-config-su.desktop
	rm /usr/share/applications/designer-qt4.desktop
	rm /usr/share/applications/linguist-qt4.desktop
	rm /usr/share/applications/assistant-qt4.desktop
	rm /usr/share/applications/qdbusviewer-qt4.desktop
	rm /usr/share/applications/qtconfig-qt4.desktop

	sed -i 's@/usr/share/argon/argon.png@gnome-app-install@' /usr/share/applications/argon.desktop
	sed -i 's@/usr/share/argon/argon.png@gnome-app-install@' /usr/share/applications/argon-notifier-config.desktop
	sed -i 's@Icon=x-office-address-book@Icon=evolution-addressbook@' /usr/share/applications/org.gnome.Contacts.desktop
	sed -i 's@Icon=xterm-color_48x48@Icon=xorg@' /usr/share/applications/xterm.desktop
	sed -i 's@Icon=tracker@Icon=preferences-system-search@' /usr/share/applications/tracker-preferences.desktop
	sed -i 's@Icon=sbackup-restore@Icon=grsync-restore@' /usr/share/applications/sbackup-restore.desktop
	sed -i 's@Icon=sbackup-conf@Icon=grsync@' /usr/share/applications/sbackup-config.desktop
	cp -f /etc/apricity-assets/playonlinux.png /usr/share/playonlinux/etc
	cp -f /etc/apricity-assets/playonlinux15.png /usr/share/playonlinux/etc
	cp -f /etc/apricity-assets/playonlinux16.png /usr/share/playonlinux/etc
	cp -f /etc/apricity-assets/playonlinux22.png /usr/share/playonlinux/etc
	cp -f /etc/apricity-assets/playonlinux32.png /usr/share/playonlinux/etc
	cp -f /usr/lib/os-release /etc/os-release
	chown -R root.root /usr/share/plymouth/themes/apricity
	#sed -i 's/Manjaro/Apricity OS/g' /etc/default/grub
	#grub-mkconfig -o /boot/grub/grub.cfg
	rm /usr/share/gnome-background-properties/adwaita.xml
	rm /usr/share/gnome-background-properties/gnome-default.xml
	chown -R root /etc/apricity-assets
	chmod -R 755 /etc/apricity-assets
	chmod 755 /usr/share
	chmod 755 /usr/share/applications
	chmod 755 /usr/lib
	chmod 755 /etc
