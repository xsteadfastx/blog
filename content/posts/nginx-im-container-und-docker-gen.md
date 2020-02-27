---
title: NGINX im Container und docker-gen
slug: nginx-im-container-und-docker-gen
tags:
- nginx
- docker
- linux
date: "2016-03-01T09:48:00+01:00"
author: marvin
draft: false
---
[![https://gifsboom.net/post/106865490574/fail-container-video](https://media0.giphy.com/media/achBohanYCPPG/giphy.gif)](https://giphy.com/gifs/fail-lol-achBohanYCPPG)

Das hatte ich lange auf meiner Liste. Bei mir lief immer noch der NGINX nicht im Container. Um ehrlich zu sein hatte ich mir alles schwieriger vorgestellt als es dann am Ende war. Ich halte mir immer alles in `docker-compose.yml`-Files fest.

```
nginx:
  image: nginx
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - /etc/nginx:/etc/nginx
    - /etc/letsencrypt:/etc/letsencrypt
    - /var/log/nginx:/var/log/nginx
```

Dies läßt eine funktionierende Ubuntu-NGINX-Config mit dem [offiziellen NGINX-Dockerimage](https://hub.docker.com/_/nginx/) laufen. Der NGINX macht fungiert nur als Reverse-Proxy für ein paar Anwendungen. Also werden Requests an ein Upstream Server weitergeleitet. NGINX macht manchmal Probleme wenn der Upstream Server Hostname nicht auflösbar ist und bricht dann sofort ab. Und dann sitzt man da und wundert sich wieso der Container immer wieder aussteigt. IP-Adressen sind auch auf ihre Art problematisch. Sie können sich unter Docker öfters ändern wenn man nach einem Image-Update den Container neustartet. Also was tun? Ich setze nun [docker-gen](https://github.com/jwilder/docker-gen) ein. Der überwacht den Docker-Daemon und erstellt aus einem Template Config-Files. In diesem Fall eine `upstream.conf`. Die `docker-compose.yml` sieht so aus:

```
gen:
  image: jwilder/docker-gen
  volumes:
    - /var/run/docker.sock:/tmp/docker.sock:ro
    - /opt/docker-gen:/data
  volumes_from:
    - nginx_nginx_1
  command: -notify-sighup nginx_nginx_1 -watch -only-exposed /data/nginx.tmpl /etc/nginx/upstream.conf
```

docker-gen braucht den `docker.sock` um aus dem Container mit dem Daemon zu kommunizieren. Schließlich muss er mitbekommen wenn es Veränderungen gibt. Sprich Container gestartet werden oder Container nicht mehr da sind. Ich mounte das Arbeitsverzeichnis um auf das Template aus dem Container zugreifen zu können. Dazu binde ich alle Volumes des NGINX Containers ein. Schließlich soll das finale Config-File an die richtige Stelle geschoben werden. `-notify-sighup nginx_nginx_1` sagt das er den NGINX Container neustarten soll. Mit `-watch` beobachtet er den Docker Daemon auf Änderungen. Mit `-only-exposed` werden nur Container betrachtet die Ports exposen. Dahinter kommt dann das Template welches benutzt werden soll und wohin die Finale Datei geschrieben werden soll. Ich habe mich dafür entschieden nicht die ganze `nginx.conf` aus dem Template zu generieren. Ich lasse nur die `upstream.conf` bauen. Dieses inkludiere ich dann in der `nginx.conf`.

```
upstream cloud {
                        # ownclouddocker_owncloud_1
                        server 172.17.0.6:80;
}
upstream gogs {
                        # gogs_gogs_1
                        server 172.17.0.5:3000;
}
upstream ttrss {
                        # ttrssdocker_ttrss_1
                        server 172.17.0.8:80;
}
```

Damit so eine Config erzeugt wird benutze ich dieses Template:

```
{{ range $host, $containers := groupByMulti $ "Env.VIRTUAL_HOST" "," }}
upstream {{ $host }} {

{{ range $index, $value := $containers }}

	{{ $addrLen := len $value.Addresses }}
	{{ $network := index $value.Networks 0 }}

	{{/* If only 1 port exposed, use that */}}
	{{ if eq $addrLen 1 }}
		{{ with $address := index $value.Addresses 0 }}
			# {{$value.Name}}
			server {{ $network.IP }}:{{ $address.Port }};
		{{ end }}

	{{/* If more than one port exposed, use the one matching VIRTUAL_PORT env var */}}
	{{ else if $value.Env.VIRTUAL_PORT }}
		{{ range $i, $address := $value.Addresses }}
			{{ if eq $address.Port $value.Env.VIRTUAL_PORT }}
			# {{$value.Name}}
			server {{ $network.IP }}:{{ $address.Port }};
			{{ end }}
		{{ end }}

	{{/* Else default to standard web port 80 */}}
	{{ else }}
		{{ range $i, $address := $value.Addresses }}
			{{ if eq $address.Port "80" }}
			# {{$value.Name}}
			server {{ $network.IP }}:{{ $address.Port }};
			{{ end }}
		{{ end }}
	{{ end }}
{{ end }}
}

{{ end }}
```

Damit `docker-gen` die passenden Container findet die er betrachten soll, müssen den Containern ein paar Environment-Variabeln mitgegeben werden. Hier zum Beispiel mit [Gogs](https://gogs.io):

```
gogs:
  image: gogs/gogs
  ports:
    - "3000"
  volumes:
    - "/srv/www/gogs:/data"
  environment:
    - VIRTUAL_HOST=gogs
    - VIRTUAL_PORT=3000
```

`VIRTUAL_HOST` gibt dem ganzen einen Namen. Den brauchen wir dann in der eigentlichen vhost-Config. `VIRTUAL_PORT` wird gebraucht wenn der Port nicht `80` ist. Dann ignoriert `docker-gen` sonst den Container.

Die NGINX-Config sieht dann so aus:

```
server {
        listen 443;
        server_name git.foo.bar;

        ssl on;
        ssl_certificate /etc/letsencrypt/live/git.foo.bar/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/git.foo.bar/privkey.pem;

        client_max_body_size 50m;

        location / {
                proxy_pass http://gogs;
                proxy_set_header X-Forwarded-Host $server_name;
                proxy_set_header X-Forwarded-Proto https;
                proxy_set_header X-Forwarded-For $remote_addr;
        }

}
```
 Unter `proxy_pass` taucht `VIRTUAL_HOST` wieder auf. In der NGINX Config spiegelt sich das wie folgt wieder:

```
http {

        ##
        # Basic Settings
        ##

        ...
        ...
        ...

        ##
        # Virtual Host Configs
        ##

        include /etc/nginx/conf.d/*.conf;
        include /etc/nginx/sites-enabled/*;

        ##
        # Upstream
        ##

        include /etc/nginx/upstream.conf;

}
```

Nun alles Container starten und genießen oder sowas.