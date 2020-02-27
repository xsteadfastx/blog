---
title: 'Youtube Videos über TOR downloaden '
slug: 'youtube-videos-ueber-tor-downloaden '
tags:
- youtube
- tor
date: "2014-06-06T08:59:00+02:00"
author: marvin
draft: false
---
Ihr kennt das. Man will einfach mal ein paar seiner liebstens Musikvideos auf Youtube klicken. Vor allem wenn man nicht gerade Zugriff auf seine Musiksammlung hat. Immer wieder stößt man an den Zaun des deutschen Internet-Kleingartenvereins. Danke GEMA. Nun gibt es da eine Möglichkeit. Man nimmt ein Proxy-Addon-Dingsi. Diese laufen auch, wirken aber sowas von unseriös. Dann gibt es da noch den zweiten Anwendungsfall. Man will ein Musikvideo runterladen welches sich hinter der GEMA-Blockade befindet. Erstmal kann man das Tool [youtube-dl](https://github.com/rg3/youtube-dl/) uneingeschränkt empfehlen. Ein nettes Python-Script welches nicht nur von Youtube Videos runterladen kann. Das ganze müssen wir ja irgendwie über einen Proxy oder noch besser, durch TOR schicken. Dies geht wunderbar mit `proxychains`:

	proxychain youtube-dl https://www.youtube.com/watch?v=_NfnXdXpjL0

Übrigens läuft gerade die [Tor Challenge](https://www.eff.org/torchallenge/) der EFF. Also sollte man gleich mal ein Relay aufsetzen und das Netz zu einem romantischeren Ort machen.

Danke GEMA... für nichts...