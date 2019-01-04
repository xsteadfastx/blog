Title: Wo fährt eigentlich gerade ein öffentliches Verkehrsmittel ab? 
Slug: wo-faehrt-eigentlich-gerade-ein-oeffentliches-verkehrsmittel-ab 
Date: 2014-04-08 09:23
Tags: flask, socketio, nuernberg


![nurnberg-transport-map]({static}/images/nurnberg-transport-map.jpg)

Ich taste mich gerade weiter vor. Alles so kleine Projekte um das Programmieren zu lernen. Wenn mir eine Idee kommt versuche ich es umzusetzen. Ein Freund von mir hat ein [Python-Modul](https://github.com/derphilipp/vagquery) gebaut um Daten der öffentlichen Verkehrsmittel in Nürnberg abzugreifen. Man kann auf die Schnittstellen zugreifen die wohl auch die Anzeigen an den Haltestellen benutzen. Zum Beispiel welche Linien in wieviel Minuten ankommen. Dazu braucht man die ID der Haltestelle. Eswird auch übermittelt ob das Verkehrsmittel sich verspätet. Wie kann ich also schauen wo sich ungefähr ein Verkehrsmittel befindet? So genau geht es nicht (zumindestens soweit ich gerade denke). Ich schaue also ob die Ankunftszeit an der Haltestelle bei null Minuten ist. Es werden alle Stations-IDs abgearbeitet und ein GeoJSON gebaut. Dieses wird dann per socket.io auf eine [leaflet.js](http://leafletjs.com/) Karte projiziert. Alles nicht so elegant wie ich es mir gewünscht habe. Hier geht es zum [Code](https://github.com/xsteadfastx/nurnberg-transport-map). [Aber erstmal läuft es](http://nurnberg-transport-map.xsteadfastx.org)...
