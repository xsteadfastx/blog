---
title: 'Tarball von Github via curl ziehen '
slug: 'tarball-von-github-via-github-ziehen '
tags:
- github
- curl
date: "2014-09-25T12:16:00+02:00"
author: marvin
draft: false
---
Schon was mich bei Sourceforge wahnsinning genervt hat: Es gab keinen schönen Link den man in wget werfen konnte um an sein Install-Paket zu kommen. Immer war da dieser Rattenschwanz an Mirror-Url-Zeug am Filename. Ich liebe es ja wenn es Seiten dazu optimiert sind schnell mal per Shell was auf den Computer laden zu können. Will man ein Tarball von GitHub saugt `curl` oder `wget` oft nur die Redirect-Website und nicht das eigentliche File. Ein großes meh. Wie lange ich gehscuat habe wie ich an den richtige Link komme. Bis sich rausstellte das ich vielleicht mal was an meinem `curl`-Aufruf ändern könnte.

	curl -LOk https://github.com/xsteadfastx/blog/archive/master.zip

Und es funktioniert. Ich kann mich immer nur selber ermahnen: RTFM!!1!!!!1!einself