Title: Beets und Verschiebungen 
Slug: beets-und-verschiebungen
Date: 2014-03-16 09:10
Tags: beets, music


Viel Zeit habe ich im beets IRC-Channel verbracht. Auch wenn die Dokumentation reichlich ist, war mir einiges Verhalten dann doch nicht so klar. Wenn ich Sachen importiert habe die entweder keinen Eintrag bei musicbrainz haben oder von Discogs kommen, sind die Artists-Tags unterschiedlich. Zum Beispiel bei den Hörbüchern von C.S. Lewis. Ein Hörbuch war bei musicbrainz und war getaggt mit "C.S. Lewis". Ein anderes wiederum habe ich einfach wie es ist importiert (dies geht auch. Zum Beispiel um trotzdem eigene Sachen in der Musiksammlung zu haben). Es hat den Artist-Tag "C. S. Lewis". Ist vielleicht im ersten Augenblick nicht so schlimm, verhagelt einem aber die Verzeichnisstruktur. Nun gibt es den beets-Befehl `beet modify QUERY artist="C.S. Lewis"`. Dieser sollte das hier machen:

> Supply a query matching the things you want to change and a series of field=value pairs. For example, beet modify genius of love artist="Tom Tom Club" will change the artist for the track “Genius of Love.” The -a switch operates on albums instead of individual tracks. Items will automatically be moved around when necessary if they’re in your library directory, but you can disable that with -M.

Also habe ich versucht den Artist-Tag zu verändern. Dies klappte auch wunderbar, nur verschob er die Files nicht in das passende Verzeichnis "C.S. Lewis". Ich probierte rum. Ich versuchte den Befehl `beet move` (von dem ich bis jetzt auch nicht wirklich weiß was er macht). Nichts passierte. Ich versuchte den albumartist-Tag zu verändern. Wieder änderte er den Tag, verschob die Dateien aber nicht. Ich fragte im IRC und viele waren verwundert das es bei mir nicht geht. Nachdem ich es auf einer zweiten Box getestet hatte, und da das gleiche verhalten hatte, schrieb ich einen [Bugreport](https://github.com/sampsyo/beets/issues/613). Ein paar Minuten später hatte ich die Antwort: 

> I think you want to modify the album-level structure and the albumartist field: `beet modify -a foo albumartist="bar"`

Und das war es. Zusätzlich sollte man noch ein `beet modify -a C.S. Lewis artist="C.S. Lewis" machen`. Damit artist-, und album-Tag zusammen passen. Und ich muss ehrlich sein: Der Sinn von "-a" ist bis noch überhaupt nicht klar. Was heißt das er es auf das Album anwendet? Ich dachte er würde immer individuell schauen und dann die Files anpassen. Zumindestens geht es schon einmal. Und wenn es das tut, ist es ein großartiges Tool, auch wenn ich oft an der Dokumentation scheitere....  
