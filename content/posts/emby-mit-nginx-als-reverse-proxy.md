---
title: Emby mit NGINX als Reverse-Proxy
slug: emby-mit-nginx-als-reverse-proxy
tags:
- emby
- nginx
- linux
date: "2015-11-19T15:19:00+01:00"
author: marvin
draft: false
---

Ich bin ja vor einiger Zeit von [Plex](https://plex.tv/) auf [Emby](http://emby.media) gewächselt um sich meiner Mediendateien anzunehmen. Auch wenn Plex seinen Job gut machte, gibt es dort in mir ein kleinen Ort der bei nicht Open-Source Software ein wenig rebelliert und sich nicht so fluffig anfühlt. Zum Glück gibt es Emby. Es fühlt sich an manchen Ecken noch nicht so perfekt an wie Plex, macht seinen Job aber anständig. Dazu kommt ein Feature was ich stark vermisst habe: Encoding bei Audio-Files. Ich will über mein Handy kein [FLAC](https://de.wikipedia.org/wiki/Free_Lossless_Audio_Codec) streamen. Emby kann auch Serien selber verwalten. Das bedeutet, dass man die Files in ein Verzeichnis schmeißt und Emby die dann umbenennt und wegsortiert. Emby läuft bei mir in einem [Docker Container](https://hub.docker.com/r/emby/embyserver/) und ich leite den Port an meinem Router weiter. Eine noch schönere Lösung ist ein Reverse-Proxy. Dann könnte alles unter einer Subdomain aufrufbar sein. Ein [NGINX](http://nginx.org/) ist schon im Einsatz. Als Proxy für ein paar andere Docker Container. Also wieso nicht einfach auch für Emby benutzen? Bis jetzt läuft auch alles ziemlich gscheit.

    server {
        listen 80;
        server_name emby.meinedomain.tld;

        keepalive_timeout 180;
        client_max_body_size 1024M;

        location / {
            proxy_pass http://127.0.0.1:8096;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-for $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto $remote_addr;
            proxy_set_header X-Forwarded-Protocol $scheme;
            proxy_redirect off;

            # Send websocket data to the backend aswell
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }

Wichtig ist hier auch der Teil mit dem Websockets. Die müssen natürlich auch weitergeschubst werden. Zum Glück bietet NGINX da den passenden [Support](https://www.nginx.com/blog/websocket-nginx/). Ja ich weiß, noch kein SSL. Wird aber nachgeholt.

Danke an [Karbowiak](http://emby.media/community/index.php?/topic/22889-emby-behind-a-reverse-proxy-remote-control-issue/?p=225882).