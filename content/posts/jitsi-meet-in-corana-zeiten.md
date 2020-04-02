---
title: "Jitsi-Meet in Corana Zeiten"
date: 2020-04-02T15:15:25+02:00
slug: jitsi-meet-in-corana-zeiten
tags:
  - jitsi
  - communication
  - voip
  - linux
  - docker
  - ansible
  - golang
  - covid19
  - prometheus
  - raspberrypi
draft: false
---

Social Distancing gehört eigentlich zu meinen Stärken. Soziale Kontakte kostet mich einen riesigen Aufwand. Auf einmal wurden wir alle Zuhausebleiber zu Helden der Corona-Zeit. Ich hätte es nicht gedacht, diese Distanz tat mir nicht gut. Ich scrollte durch viele "witzige" Screenshots von Gruppenvideochats.

Vor ein paar Jahren probiere ich mal [Jitsi-Meet](https://jitsi.org/) aus. Ein kleiner Testlauf für die Firma, mit mäßigen Erfolg. Ab drei Teilnehmern ging der Server in die Knie. Nachdem ich [diesen Bugreport](https://github.com/jitsi/jitsi-meet/issues/4758) sah, wurde mich auch klar wieso: Es gibt ein Firefox Bug, der die Verbindungen stark einschränkt, und das für alle Beteiligen. Egal. Ich kannte Jitsi schon aus meinen XMPP-Hype Jahren. Damals noch als Java Client der auch schon Audio und Video kannte. Er nutze dabei [XMPP Jingle](https://xmpp.org/extensions/xep-0166.html) für das Aushandeln der Verbindungen. Da ich keine Lust darauf habe kommerzielle, closed Source Geschichten zu benutzen (aus Überzeugung), wollte ich etwas eigenes Aufsetzen. Jitsi musste wieder her halten.

In meiner Fantasie als Mega Super Admin  rolle ich gleich mehrere Instanzen aus. Aus diesem Grund muss es eine [Ansible Rolle](https://github.com/xsteadfastx/ansible-xsfx-jitsi_meet) sein. Diese wäre Teil meiner persöhnlichen Infrastruktausrollung. Ich schlug mich durch bereits vorhandene [Ansible Rollen](https://github.com/UdelaRInterior/ansible-role-jitsi-meet/issues/5). Ein scharzer Tag innerhalb schwarzer Tage. Ich setze immer wieder frische virtualle Hetzner Server auf. Egal ob Debian oder Ubuntu, immer bekam ich andere Fehler. Anscheinend baut Jitsi intern viel um und will nun NGINX als neuen als Reverseproxy nutzen. Zumindestens nehme ich diese Aussage als Ausrede meines Nichtkönnens. Es gab aber noch eine andere Alternative: das [docker-compose Setup](https://github.com/jitsi/docker-jitsi-meet). Aufgesetzt, funktioniert. Wieso also der Hassle?

Meine [Ansible Rolle](https://github.com/xsteadfastx/ansible-xsfx-jitsi_meet) setzt ein funktionierendes Docker Setup voraus. Dann als Ansible Variabel den Host setzen:

        jitsi_meet__host: foo.bar.tld

Die meiste Arbeit steckt in dem offiziellen docker-compose File. Es kümmert sich sogar um letsencrypt SSL Zertifikate. Ich klickte mir erstmal den billigsten [vServer in der Hetzner-Cloud](https://www.hetzner.de/cloud). Natürlich muss ich auch mitbekommen wie sich die Zahlen der Konferenzen und User auf den Ressourcen-Verbrauch auswirkt. Ich brauchte einen [Prometheus](https://prometheus.io/) Exporter. Auch hier gab es [was](https://github.com/karrieretutor/jitsi-prom-exporter), dies beinahaltet Gefummel am XMPP Server. Keine Lust darauf wenn ich sowas automatisiert ausrollen möchte. Und da ich gerade eh mit [go](https://golang.org/) rumspiele musste ich es einfach selber machen. Stellt sich raus, die Videobridge Komponente in Jitsi kann [Statistiken](https://github.com/jitsi/jitsi-videobridge/blob/master/doc/statistics.md). Ich nehme die angebotenen Werte und baue daraus Prometheus Metriken. Ein Hack. Aber es macht was es soll. Der [jitsiexporter](https://github.com/xsteadfastx/jitsiexporter)!

Nun treffen wir uns einmal Morgends, frühstücken zusammen. Ich habe soviel soziale Kontakte wie noch nie. Diese Zeiten erzeugen eine Sensucht nach Nähe. Dies ist priviligiertes Gejammer aus der Quarantäne, das ist mir bewusst.
