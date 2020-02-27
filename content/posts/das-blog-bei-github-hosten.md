---
title: 'Das Blog bei GitHub hosten '
slug: 'das-blog-bei-github-hosten '
tags:
- github
- blog
- pelican
date: "2014-02-06T15:10:00+01:00"
author: marvin
draft: false
---

Ich musste mich irgendwann entscheiden. Seit Jahren habe ich kaum praktischen IT-Kram gebloggt. Irgendwie hat es sich so ergeben, dass ich dies nicht in mein normales Blog schreiben wollte. Und immer wieder kam es vor das ich mir kniffe ergoogelt oder erfragt habe und die in irgendeiner Weise teilen wollte. Ich bin doch bestimmt nicht der erste der wissen will wie man OpenVPN unter Windows als Dienst laufen lassen kann. Dazu kam natürlich der Wunsch meine Programmier-Experimente zu dokumentieren und Erfahrungen aufzuschreiben. Das ganze sollte simpel gehalten werden. Keine Datenbank und am besten mit Markdown-Support. Es wurde [Pelican](http://blog.getpelican.com/). Ein Python-Generator der aus Markdown statische Seiten knuppert. Python... passt! Dann hatte ich mal gelesen, dass man auf GitHub auch Seiten hosten kann. Und zwar statische Seiten. Perfekt. Ich wollte das Blog eh in einem GIT-Repository verwalten. Wer hätte gedacht das ich mir wirklich ein paar Stunden die Zähne ausbeißen würde um zu verstehen wie GitHub das nun macht. Man muss die HTML-Files in einem Branch mit dem Namen "gh-pages" ablegen. Dann gibt es wohl einen Unterschied zwischen User-Site und Project-Site. Die User-Site ist unter "username.github.io" erreichbar. Eine Project-Site unter "username.github.io/project". In die Falle in die ich getappert bin war: Bei der User-Site müssen die HTML-Files direkt im master-branch liegen und nicht unter "gh-pages". Dies gilt nur für die Project-Sites. Also erstmal ein Repo mit dem Namen "blog" angelegt und geklont. Darin kommen dann die Markdown-Files und der ganze Pelican-Config-Kram und das Theme. Die ".gitignore" habe ich um "output" erweitert. So pushe ich nur die Files die ich zur Blog-Erstellung brauche in den master, aber nicht die HTML-Files selber. Es gibt ein nettes Python-Script mit dem Namen "ghp-import".

	:::bash
	ghp-import output

Damit lädt er den Inhalt des Output-Folders in den "gh-pages"-Branch. Pusht man den nun auf GitHub, läuft alles und ist unter "http://username.github.io/blog" erreichbar. 