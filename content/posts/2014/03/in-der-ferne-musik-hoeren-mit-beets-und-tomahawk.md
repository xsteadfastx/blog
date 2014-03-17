Title: In der Ferne Musik hören, mit Beets und Tomahawk 
Slug: in-der-ferne-musik-hoeren-mit-beets-und-tomahawk 
Date: 2014-03-17 16:32
Tags: beets, music, tomahawk


Ich muss mein Homeoffice für ein paar Tage in ein anderen Ort verlegen. Wie komme ich nun an meine inspirierende Musiksammlung auf dem Homeserver? Da ich [MPD](http://www.musicpd.org/) benutze, habe ich noch schnell ein Streaming Output definiert.

	audio_output {
		type            "httpd"
		name            "My HTTP Stream"
		encoder         "lame"
		port            "8000"
		quality         "5.0"
	}

Den MPD-Daemon bediente ich per ssh und hörte den Stream per VLC. Eigentlich ganz ok. Als ich mich noch mehr mit [Beets](http://beets.radbox.org/) beschäftigte, probierte ich das Web-Plugin aus. Dies konnte nicht viel. Vor allem keine Chance meine FLAC-Files zuhören wegen fehlenden HTML5-Support. Nun kommt der Cloud: Das Web-Plugin von Beets ist per API erreichbar und mit [TOMAHAWK](http://www.tomahawk-player.org/) nutzbar. Ein Player von dem ich bis jetzt nichts gehört habe. TOMAHAWK ist sowas wie ein Frontend für allerlei Streamingdienste und kann auch noch viel mehr. Zum Beispiel Library-Sharing über XMPP. Habe ich alles noch nicht getestet. Das Beets-Addon funktioniert perfekt. Streamen der kompletten Sammlung. Endlich mal gscheite Musik, egal wo ich bin.	
