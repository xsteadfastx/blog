---
title: Audio überall. Mopidy und Snapcast
slug: audio-uberall-mopidy-und-snapcast
tags:
- mopidy
- linux
- raspberrypi
- python
date: "2016-12-14T13:00:00+01:00"
author: marvin
draft: false
---
[![](https://media3.giphy.com/media/3ohA2ToqrPmluotB5u/giphy.gif)](https://giphy.com/gifs/gilmoregirls-netflix-gilmore-girls-3ohA2ToqrPmluotB5u)

Musik hören geht alle Zeiten wieder durch mehrere Iterationen. Von wild, ungetaggten, Files die ich bin [XMMS](http://www.xmms.org/) abspielte, über die ersten Versuche mit einer Verwaltung unter [Amarok](https://amarok.kde.org/de) und eine sehr düstere Zeit mit, dem vom Herzen tiefst gehassten, iTunes. Das erste Licht am Ende des Tunnels sah ich mit [MPD](https://www.musicpd.org/) und dem Feature von [ncmpcpp](https://rybczak.net/ncmpcpp/) Tags und Files umzubenennen und richtig zu taggen. Später dann mit [Picard](https://picard.musicbrainz.org/) vom [MusicBrainz](https://musicbrainz.org/) Projekt. Dann kam ich schnell auf ein Kommandozeilen-Tool was dies auch ganz wunderbar kann: [beets](http://beets.io/). Ab da wollte ich mir nicht mehr von anderen Programmen in meine Files schreiben lassen und erst recht nicht sortieren. Nun gibt es Clouds oder ähnliche Marketingkonstrukte und man installiert sich Software auf dem Heimserver wie [Plex](https://www.plex.tv/de/) oder seine Open-Source-Alternative [Emby](https://emby.media/). Mit diesen Diensten kann man seine Mediensammlung theoretisch über das Internet konsumieren. Klappt in den besten Fällen ziemlich gut. Gerade die UI von Emby kommt mir ziemlich behäbig vor (kann natürlich auch an meinem Server liegen). Ich erinnerte mich an meine unbeschwerte Zeit mit MPD. Alles flutschte und funktionierte mit den verschiedensten Clients. Nun gibt es ein kleines Projekt mit dem Namen [Mopidy](https://www.mopidy.com/). Ein in Python geschriebener Audio Server der so tut als ob er MPD ist aber noch viel mehr zu bieten hat. Es gibt Plugins um auf die verschiedensten Bibliotheken zuzugreifen. Unter anderem Spotify, Youtube, Google Music, usw. Also habe ich mich mal ran gesetzt und ein [Emby Plugin](https://github.com/xsteadfastx/mopidy-emby) geschrieben. Nun kann ich das langsame UI umgehen und viele weitere Möglichkeiten machen sich auf.

Ich lasse Mopidy und Snapcast in einem Docker Container laufen. [Snapcast](https://github.com/badaix/snapcast) bietet Multi-Room Streaming. Mehrere Devices die über das Netz ihren Output synchronisieren und das bei mir sogar über ein VPN hinweg. So kann ich Raspberry Pi's über all im Haus verteilen. Diese starten dann den `snapclient` nach dem booten und die Musik spielt ab.

Mopidy muss dazu den Output in ein FIFO-File schreiben. Dazu muss in der Config folgendes stehen:

```
[audio]
output = audioresample ! audioconvert ! audio/x-raw,rate=48000,channels=2,format=S16LE ! wavenc ! filesink location=/tmp/snapfifo
```

Den Server startet man mit den Defaults mit einem einfachen `snapserver`. Der Client sollte den Server über Avahi finden. Da ich den Port an meinem Container nicht freigegeben habe mache ich das manuell mit `snapclient -h 192.168.1.77`. Mein Docker Setup findet man [hier](https://github.com/xsteadfastx/dockerfiles/tree/master/mopidy).