Title: Ein paar Plugins für Pelican
Date: 2015-09-21 15:40
Slug: ein-paar-plugins-fuer-pelican
Tags: pelican, blog, python
Description: Ich habe ein paar Plugins für  den Pelican Static Site Generator geschrieben

{% giphy YuNzqtXUcwbV6 'Wie ich mich beim coden fühle' %}

Ich bin eigentlich ziemlich glücklich mit meinem Umstieg von Wordpress auf [Pelican](http://blog.getpelican.com/). Dieses Static-Site-Ding macht in meinen Augen wirklich Sinn. Vor allem passt es sich gut in diesen GIT-Workflow ein. Alles in Markdown und keine DB im Nacken plus Backups die durch GIT ganz wunderbar sind. Meine Entscheidung für Pelican fiel durch die Programmiersprache Python. Ich dachte es ist schön wenn man fähig ist ein wenig zu verstehen was dort passiert und es eventuell die Möglichkeit gibt auch etwas dem Projekt zurück zu geben. Dies habe ich nun mit ein paar Erweiterungen für das [liquid_tags](https://github.com/getpelican/pelican-plugins/tree/master/liquid_tags) Plugin getan. Ich habe gemerkt das ich oft viele Sachen einbinde und dies frisst Zeit sich erstmal die Embeded-Codes rauszusuchen oder selber zu basteln. Dies soll für einige Dienste nun durch diese Erweiterungen verbessert werden.

## flickr
Hier war das Problem anhand der ID an alle Informationen zu kommen um das HTML-Tag zu bauen. Ich habe mich dazu Entschieden einfach die Flickr-API zu nutzen. Dies ist natürlich nicht der optimalste Weg, es funktioniert aber. Um die API zu nutzen braucht man erstmal einen [Key von Flickr](ttps://www.flickr.com/services/apps/create/apply). Den packt man in die Pelican-Config unter der Variable `FLICKR_API_KEY` und schon kann man aus

	\{\% flickr 18841046161 large 'Ich denke an einen Wald' \%\}

folgendes basteln:

![Ich denke an einen Wald]({static}/images/18841046161_de05aa1433_b.jpg)

Für alle Optionen schaut man [hier](https://github.com/getpelican/pelican-plugins/blob/master/liquid_tags/flickr.py) vorbei.

## soundcloud
Was ich auch gerne tue, ist Soundcloud Widgets einbinden. Und hier mein großer Respekt an die API. Es gibt einen Endpoint der einem gleich den Embeded-Code liefert. Alles was man tun muss ist die Track-Url mitgeben. So wird aus

	\{\% soundcloud https://soundcloud.com/luftmentsh/hakotel \%\}

dies hier:

{% soundcloud https://soundcloud.com/luftmentsh/hakotel %}

Den Code gibt es [hier](https://github.com/getpelican/pelican-plugins/blob/master/liquid_tags/soundcloud.py).

## giphy
Manche Sachen sagt man besser mit einem GIF. Ja, es macht jedes zweite Blog. Egal... es ist wunderbar. Noch einfacher wenn man mit einem einfachen Tag [Giphy](http://giphy.com)-Animationen einbinden kann. Dank der API (wiederum braucht man einen [Key](https://github.com/giphy/GiphyAPI)) ging das auch ziemlich einfach. Key in die Config (`GIPHY_API_KEY`) und es kann los gehen.

	\{\% giphy y6Nhc2E1ch2ww \%\}

{% giphy y6Nhc2E1ch2ww %}

Den Code gibt es [hier](https://github.com/getpelican/pelican-plugins/blob/master/liquid_tags/giphy.py).

## html5 audio
Manchmal wollte ich Audio-Beiträge vom Deutschlandfunk verlinken. Diese bieten kein Widget zum einbinden. Man bekommt nur die reinen MP3-Files. Das schönste ist natürlich wenn man das Audio-Tag benutzt welches es seit HTML5 gibt. Also kein komischer Flash-Player. Natürlich gibt es immer noch riesen Probleme zwischen Audioformat und Browser und Betriebssystem. Deswegen kann man mehrere Sources pro Player einbinden. Dies geht auch mit diesem Plugin.

	\{\% audio http://media.w3.org/2010/07/bunny/04-Death_Becomes_Fur.mp4 http://media.w3.org/2010/07/bunny/04-Death_Becomes_Fur.oga \%\}

{% audio http://media.w3.org/2010/07/bunny/04-Death_Becomes_Fur.mp4 http://media.w3.org/2010/07/bunny/04-Death_Becomes_Fur.oga %}

Den Code gibt es [hier](https://github.com/getpelican/pelican-plugins/blob/master/liquid_tags/audio.py).
