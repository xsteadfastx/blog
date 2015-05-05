Title: Weg mit dem Splashscreen
Date: 2015-05-05 12:06
Tags: ubuntu, linux
Slug: weg-mit-dem-splashscreen


Irgendwie habe ich auf 90% der Linux Systeme Probleme mit dem Splashscreen bei Booten. Manchmal taucht er einfach nicht auf und manchmal ist irgendein Foo mit der Auflösung. Eigentlich brauche ich den Splashscreen auch nicht. Also weg damit...

Unter Ubuntu geht es wie folgt. Man editiert `/etc/default/grub`:

    GRUB_CMDLINE_LINUX_DEFAULT=""

Und danach updated man GRUB mit:

    sudo update-grub

Zack... Fertig!
