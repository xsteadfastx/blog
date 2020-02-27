---
title: Linux Audio an UPNP und Chromecast
slug: linux-audio-an-upnp-und-chromecast
tags:
- linux
date: "2017-09-05T09:54:00+02:00"
author: marvin
draft: false
---
Ich sitze krank zuhause. Was stellt man an? Der Kopf brummt und das so laut und intensiv, dass man am besten, natürlich kontraproduktiv, an seinem Linux-Audio-Setup rumschraubt. Oder ist dies der Grund für mein Unbehagen? Was kann denn da schon schiefgehen? Ich starte mal mit einem kleinen Schaubild meines Setups.


```
                                                +------------------------+
                                                |                        |
                                                |                        |
+----------------------+                   +----v-----+                  |
|  firefox/mpv/...     |                   |          |                  |
|  through pulseaudio  |         +---------+  client  +------------+     |
+------------+---------+         |         |          |            |     |
             +                   |         +----------+            |     |
         streaming           streaming                             |     |
             +                   |                                 |     |
   +---------v---------+         |                                 +     |
   |                   |   +-----v------+                       control  |
   |  pulseaudio+dlna  +--->  upmpdcli  |                          +     |
   |                   |   +-----+------+                          |     |
   +-------------------+         |                                 |     |
                             streaming     +----------+            |     |
                                 |         |          |            |     |
                                 +--------->  mopidy  <------------+     |
       +------------------+            +--->          |                  |
       |      sources     |            |   +----+-----+                  |
       |(emby/youtube/...)+-streaming--+        |                        |
       +------------------+                +----v-----+                  |
                                           | snapcast |                  |
                                           +----+-----+                  |
                                                +                        |
                  +------------------+      streaming                    |
                  |                  |          +------------------------+
                  |   snapclient on  |          |
                  |   raspberry pi   <----------+
                  |                  |          |
                  +------------------+          |     +--------------+
                                                +-----> more         |
                                                      | snapclients  |
                                                      +--------------+

```

Im Endeffekt ist die Schaltzentrale [mopidy](https://www.mopidy.com/) mit seiner Möglichkeit Audio aus mehreren Sourcen entgegen zu nehmen und sie auch auf verschiedenste Möglichkeiten wieder auszugeben. Der Grundgedanke mit `mopidy` war wohl: ein Server der über das Netzwerk Lieder entgegennimmt und sie dann über, die an dem Server angeschlossenen, Lautsprecher abspielt. Nun sind wir im großen Streaming-Zeitalter und wieso sollte ich für jeden Raum den ich bespielen möchte einen `mopidy`-Dienst betreiben? Also schiebt `mopidy` seinen Output in einen [snapcast](https://github.com/badaix/snapcast)-Server, der dann von vielen Clients angefragt werden kann und das Audio versucht, synchronisiert, abzuspielen. Daran können viele Clients sich ihr Audio abholen. Ich habe einen Raspberry Pi im Wohnzimmer an meine Stereoanlage angeschlossen auf dem ein snapcast-Client läuft. Zusätzlich nutze ich die snapcast-App auf meinem Telefon an dem ich Aktivlautsprecher anschließe und diese in der Küche betreibe. Funktioniert sehr gut. Sogar über VPN nutze ich `snapcast`. So kann ich per `mopidy` mir Lieder auswählen, aus egal welchen Quellen, und sie dann einfach abspielen, egal wo ich bin. Eine Komponente ist [upmpdcli](https://www.lesbonscomptes.com/upmpdcli/). Damit läßt sich `mopidy` durch [MPD](https://www.musicpd.org/)-Clients steuern. Der Clou: Man kann sogar per UPNP Tracks durch `upmpdcli` zu `mopidy` durchreichen. Dies funktioniert nicht immer perfekt aber immer wieder überraschend gut. Nun fing ich an zu googeln. Es wäre natürlich am schönsten, wenn ich so auch Inhalte meines Laptops in mein Audio-Setup geben könnte. Und natürlich gab es da etwas: [pulseaudio-dlna](https://github.com/masmu/pulseaudio-dlna)! Und wer hätte das denken können: ich bin mittlerweile voll auf dem Pulseaudio-Zug, begeistert, aufgesprungen. Hat ja nur wie lange gedauert? Zehn Jahre? Damals wurde es zu dem Standard in Ubuntu und alles was es konnte war, dass es keinen Sound mehr gab. Zumindestens auf meinem System. Nun nutze ich es gerne für genau solche Setups. Man started `pulseaudio-dlna` und öffnet `pavucontrol`. Spielt nun ein Programm Audio ab, kann man es über einen UPNP-Renderer (in meinem Fall `upmpdcli` + `mopidy`) ausgeben lassen oder sogar über einen Chromecast. 

Übrigens versuche ich die meiste Software für [Alpine Linux](https://alpinelinux.org/) zu Verfügung zu stellen, wenn es sie nicht schon gibt. Ich versuche all meine Docker-Images auf Alpine basieren zu lassen. So kommt alles aus einem Guss und ich kann auch noch ein wenig diese tolle Distro unterstützen.

Mein ganzes Setup ist in Docker gegossen. Alles dazu findet man [hier](https://github.com/xsteadfastx/dockerfiles/tree/master/mopidy).