Title: Das Letsencrypt Docker Moped
Date: 2015-12-07 16:17
Slug: das-letsencrypt-docker-moped
Tags: docker, linux, letsencrypt, ssl, nginx

Darauf haben wir lange gewartet: SSL für alle!!1!!!111! Wie oft musste ich Leuten erzählen das sie keine Angst haben müssen vor dem Polizisten mit dem Schlagstock (zumindestens nicht vor dem im Chrome Browser). Ich hatte persöhnlich nie etwas gegen selbstsignierte Zertifikate, wenn ich nicht gerade Geld über diese Seiten schubsen musste. Aber könnte nun alles der Vergangenheit angehören. [Letsencrypt](https://letsencrypt.org) bieten nun einen einfachen Weg an um sich seine Zertifikate unterschreiben zu lassen. Und nicht nur das. Sie wollen Tools mitliefern, die ohne viel Vorwissen die Arbeit für einen erledigen. Sprich Keys erzeugen und den Zertfikatsrequest. Dann findet eine überprüfung statt ob die Domain für die ihr das Zertifikat haben wollt, auch wirklich euch gehört. Ein wichtiger Schritt. Nur weil ihr keine Hunderte von Euro für ein Zertifikat ausgibt, sollt ihr trotzdem das Recht haben das der Transport über das Netz verschlüßelt ist. Ohne Schlagstock-Polizisten-Warning. Nun geht das Projekt in die BETA-Phase und die [üblich Verdächtigen](http://blog.fefe.de/?ts=a89f4ed6)(WARNUNG: fefe link) ranten rum. Räudiges Python und alles viel zu einfach... und vor allem... jeder weiß doch wie man openssl richtig bedient und wo man richtige Zertifikate bekommt. Ich finde den Ansatz gut. Natürlich ist der Client noch nicht dort angekommen wo er ankommen will. Aber es funktioniert. Der Client bietet mehrere Modi an. Der eine öffent die Ports 80 und 443 und Letsencrypt schaut dann ob sie erreichbar sind und tauschen ein paar Sachen aus. Problem: Auf dem Server läuft meist schon ein Webserver und blockiert die Ports. Ich muss also NGINX stoppen, den Client starten und dann NGINX wieder anschieben. Irgendwie nicht so schön. Eine andere Möglichkeit ist `webroot`. Dafür legt der Client ein paar Ordner in das Root-Verzeichnis des Webservers und der Dienst schaut dann dort nach. Problem hierbei: Ich habe in meine NGINX keine Files im Root. Ich benutze NGINX nur als Reverse-Proxy. Es gibt Hilfe:

Das NGINX Snippet
-----------------

```
location /.well-known/acme-challenge {
    alias /etc/letsencrypt/webrootauth/.well-known/acme-challenge;
    location ~ /.well-known/acme-challenge/(.*) {
        add_header Content-Type application/jose+json;
    }
}
```

Und wenn wir dieses Snippet nun in den `server`-Teil der NGINX config "includen" haben wir die passende Location damit Letsencrypt alles findet.

Letsencrypt im Docker-Container
-------------------------------

Der Client versucht sich vor jedem Ausführen nochmal selber zu updaten. Keine schlechte Idee in der BETA-Phase. Ich dachte nur ich versuche alles ein wenig aufzubrechen und in ein Docker-Image zu gießen. Dies sollte (Dank [Alpine-Linux](https://hub.docker.com/_/alpine/)) schön klein Sein und schon alle wichtigen Optionen im `ENTRYPOINT` beinhalten. Das man nur noch die Domains, für die man Zertifikate haben will, anhängt. Der Gedanke dahinter: Man kann es einfach in die Crontab packen und alle Abhängigkeiten sind im Container gefangen. Die Repo liegt [hier](https://github.com/xsteadfastx/letsencrypt_docker). Für noch mehr Convenience nutze ich auch mein geliebtes [docker-compose](https://docs.docker.com/compose/).

```
letsencrypt:
  build: letsencrypt/
  volumes:
    - /etc/letsencrypt:/etc/letsencrypt
    - /var/lib/letsencrypt:/var/lib/letsencrypt
  environment:
    EMAIL: marvin@xsteadfastx.org
    WEBROOTPATH: /etc/letsencrypt/webrootauth
  command:
    "-d emby.xsteadfastx.org -d cloud.xsteadfastx.org -d reader.xsteadfastx.org -d git.xsteadfastx.org"
```

Ich benutze Compose so oft wie es geht. Dort kann ich schön alles definieren wie der Container ausgeführt werden soll. Eine saubere Sache. Erstmal werden die Volumes eingebunden. Diese beiden Verzeichnise braucht der Letsencrypt-Client. Dann werden zwei Environment-Variablen definiert. Email und der Pfad in dem der Client die Files zur Authentifizierung ablegt. Als `command` werden die Domains jeweils mit der Option `-d` angehängt. Mit `docker-compose up` wird erst das Image gebaut und dann ausgeführt.

Ich bin gespannt wie es weitergeht. Natürlich ist mein Container auch nur der erste Entwurf... aber ich werde weiter daran basteln.
