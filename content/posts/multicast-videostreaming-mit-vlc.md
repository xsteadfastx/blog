Title: Multicast-Videostreaming mit VLC 
Slug: multicast-videostreaming-mit-vlc
Date: 2014-11-06 09:37
Tags: vlc, videostreaming, multicast

Es wird der Tag kommen an dem ich mir noch einen Raspberry Pi inklusive Camera-Modul besorge. Dann steht der Hamster-Livecam nichts mehr im Weg. Ich muss gestehen: Mit Multicast Videostreams hatte ich bisher noch keine Berührungspunkte. Also habe ich mich gestern mal auf eine Google-Suche begeben. 


### Einfaches Beispiel

Hier das Kommando welches bei mir funktioniert hat:

	cvlc -vvv Videos/meintollesvideo.mp4 --sout udp://239.1.2.3:1234 --ttl 1 --loop

Alles total straight-forward. Ich habe den Part über Transcoding erstmal rausgelassen. In diesem Fall war das mp4 hier absolut brauchbar zum streamen. Nun der wichtige Part:

`-vvv Videos/meintollesvideo.mp4`: Wenn mich nicht alles täuscht macht `-vvv` ein sehr ausgabeliebendes Loglevel. Dahinter kommt das Video was wir streamen möchten.

`--sout udp://239.1.2.3:1234`: Hier passiert schon einiges der Magic. Wir streamen über UDP und die Adresse `239.1.2.3` befindet sich im Bereich der Multicast-Adressen.

`--ttl 1`: Dies gibt die Time-To-Live an. Wieviele Hops der Multicast überlebt.

`--loop`: Ja, was macht das wohl? In meinem Test war es nicht schlecht einfach ein Video zu loopen damit ich die Fehlerquelle "Video ausgegangen" ausschließen kann. 

Zum Abspielen kann man VLC starten und über die Netzwerkstream-Adresse `udp://@239.1.2.3:1234` darauf zugreifen.


### Transkodieren und Streamen

Die Syntax zum transkodieren unter VLC sind für das ungeübte Auge auf den ersten Blick wirklich zum verzweifeln. Und ich habe zwei ungeübte AUgen. Es gibt tausende von Beispielen im Internetz. Also hier etwas was bei mir funktioniert:

	cvlc -vvv Videos/meintollesvideo.mp4 \
	--sout '#transcode{vcodec=mp4v,acodec=mpga,vb=800,ab=128,deinterlace}:rtp{mux=ts,dst=239.1.2.3}' \ 
	--ttl 1 --loop

Was ist anderes? Der `--sout` Teil sieht schon sehr anders aus. Es wird von VLC transkodiert und über RTP und Multicast gestreamt. Im Loop natürlich. Dies habe ich aus einem offiziellen VLC-Beispiel. Als Video-Codec kommt `mp4v` mit der Bitrate von `800` zum Einsatz. Als Audio `mpga` mit der Bitrate `128`. Das Video wird zu dem noch deinterlaced. Das ganze wird mit dem Muxer `ts` über die Adresse `239.1.2.3` mit einer `ttl` von `1` über Multicast rausgehauen.

Abspielen kann man es mit VLC unter der Adresse `rtp://@239.1.2.3`.


### Und was ist jetzt mit dem Raspberry Pi und dem Kamera-Modul?

Wird nachgeschoben sobald ich meine Hand auf einem passenden Gerät habe. Versprochen.


### Firewall-Regeln anpassen

Ich habe mir wirklich die Zähne ausgebissen wieso ich auf einem Ubuntu-Client um das verrecken willen keinen Stream bekam. Und es war genau das was ich eigentlich sofort hätte checken sollen: Die Firwall. Das deaktivieren brachte innerhalb einer Millisekunde das Video hervor. Also mal schnell ein paar passende Regeln hinzufügen:

	sudo ufw allow in proto udp to 239.0.0.0/4
	sudo ufw allow in proto udp from 239.0.0.0/4
