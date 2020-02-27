---
title: 'Isso ersetzt Disqus '
slug: 'isso-ersetzt-disqus '
tags:
- disqus
- isso
- blog
- supervisor
- gunicorn
- nginx
date: "2014-02-03T13:56:00+01:00"
author: marvin
draft: false
---

Disqus ist böse. Zumindestens geht das gerade ganz schön durch die Blogosphere. Mal davon abgesehen bin ich immer Fan vieles selber zuhosten. Gerade wenn man darauf steht vieles auszuprobieren und nach Alternativen zu stöbern. [bl1nk](http://kuchen.io/) hat mich dabei auf [Isso](http://posativ.org/isso/) aufmerksam gemacht. Also stand das Ganze auf meiner Liste der Sachen die ich mit Pelican machen wollte. Und schon ging es los. Das ganze sollte in einer [virtualenv](http://www.virtualenv.org)-Umgebung laufen, mit [Supervisor](http://supervisord.org/) und [gunicorn](http://gunicorn.org/) gestartet werden und durch [NGINX](http://nginx.org/) geschleust werden.

Also erstmal mit "virtualenv" die Umgebung anlegen, isso und gunicorn installieren:

	:::bash
	virtualenv isso
	cd isso
	. bin/activate
	pip install isso
	pip install gunicorn

Dies sind die drei Werte die ich in der isso.cfg (die liegt in meinem Fall unter /etc/isso/) angepasst habe:
	
	:::bash
	[general]
	# hier liegt das sqlite file mit den kommentaren
	dbpath = /var/lib/isso/comments.db

	# von diesem host werden kommentare zugelassen
	host = http://code.xsteadfastx.org/

	# isso hört auf diesem interface
	[server]
	listen = http://localhost:8004

Auf meiner Todo-Liste stehen noch Notifications per SMTP. Das kommt dann später. Supervisor habe ich mit der Distributions-Paketverwaltung installiert. Unter "/etc/supvervisor/conf.d/" habe ich "isso.conf" angelegt. 

	:::bash
	[program:isso]
	command=/srv/www/comments/bin/gunicorn -b 127.0.0.1:8004 --preload isso.run
	directory=/var/lib/isso
	environment=PATH="/srv/www/comments/bin",ISSO_SETTINGS="/etc/isso/isso.cfg"
	user=www-data
	autostart=yes

Das schöne an Supervisor ist, dass man unter "environment" gleich noch ein paar Variabeln deklarieren kann. Läuft das Isso durch gunicorn und supervisor, kann man sich um NGINX kümmern. Dazu habe ich die config angelegt:

	:::bash
	server {
		listen 80;
		server_name comments.xsteadfastx.org;
		access_log  /var/log/nginx/access.log;

		location / {
			proxy_pass http://127.0.0.1:8004;
			proxy_set_header Host $host;
			proxy_set_header X-Real-IP $remote_addr;
			proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		}
	}

Jetzt läuft schon mal Isso. Nun musste ich mein Pelican-Theme anpassen. Dazu habe ich in der "pelicanconf.py" die Variabel "ISSO_URL" eingeführt. Und "DISQUS_SITENAME" auskommentiert. 

	:::bash
	#DISQUS_SITENAME = "xsteadfastxistryingtocode"
	ISSO_URL = 'http://comments.xsteadfastx.org'

Im Theme-Template Ordner habe ich das File "isso.html" angelegt.

	:::bash
	{% if ISSO_URL %}
	  <script data-isso="{{ ISSO_URL }}"
      	    data-isso-css="true"
      	    data-isso-lang="en"
      	    data-isso-reply-to-self="false"
      	    src="{{ ISSO_URL }}/js/embed.min.js">
      	  </script>
      	  <section id="isso-thread"></section>
	{% endif %}

In "album.html" muss noch an der richtigen Stelle...
	
	:::bash
	{% include 'isso.html' %}

...eingefügt werden. Falls es nicht ganz klar ist, kann man mein Beispiel auf [GitHub](https://github.com/xsteadfastx/blog/tree/master/themes/xsteadfastx/templates) anschauen.