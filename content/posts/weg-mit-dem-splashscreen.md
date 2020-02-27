---
title: Weg mit dem Splashscreen
slug: weg-mit-dem-splashscreen
tags:
- ubuntu
- linux
date: "2015-05-05T13:06:00+02:00"
author: marvin
draft: false
---

Irgendwie habe ich auf 90% der Linux Systeme Probleme mit dem Splashscreen bei Booten. Manchmal taucht er einfach nicht auf und manchmal ist irgendein Foo mit der Auflösung. Eigentlich brauche ich den Splashscreen auch nicht. Also weg damit...

Unter Ubuntu geht es wie folgt. Man editiert `/etc/default/grub`:

    GRUB_CMDLINE_LINUX_DEFAULT=""

Und danach updated man GRUB mit:

    sudo update-grub

Zack... Fertig!