---
title: 'NGINX force https '
slug: nginx-force-https
tags:
- nginx
- ssl
- https
date: "2014-02-19T20:18:00+01:00"
author: marvin
draft: false
---

Am liebsten setze ich zur Zeit [NGINX](https://de.wikipedia.org/wiki/Nginx) als Webserver ein. Vor allem für meine Owncloud installation und ein paar Python Sachen. Das "Problem" war bis jetzt, dass er Anfragen auf "http" nicht auf "https" weitergeleitet hat. Nicht wirklich ein Problem, sondern nur nervig wenn man wiedermal vergessen hat explezit "https" davor zu schreiben. In der Config mit dem funktionierenden SSL-Server Teil schreibe ich einen zweiten "server"-Bereich:

	:::bash
	server {
		listen 80;
		server_name cloud.xsteadfastx.org;
		return 301 https://$server_name$request_uri;
	}

Viele regeln das mit Regex, laut NGINX-Wiki ist dies aber die saubere Methode. 