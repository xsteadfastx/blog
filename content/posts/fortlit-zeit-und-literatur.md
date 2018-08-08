Title: fortlit: Zeit und Literatur
Date: 2018-08-08 13:55
Slug: fortlit-zeit-und-literatur
Tags: linux, literature, books, code, python

Ich bin auf einen [Blogartikel](https://www.instructables.com/id/Literary-Clock-Made-From-E-reader/) zu einer Kindle basierten Uhr gestossen. Darin beschreibt [Jaap Meijers](http://www.eerlijkemedia.nl/) wie er zu jeder Uhrzeit ein Zitat aus der Literatur auf dem Kindle darstellt. Er nutzt dazu [Daten des Guardians](https://www.theguardian.com/books/table/2011/apr/21/literary-clock?CMP=twt_gu), die Zeiten aus Büchern sammeln ließen. Sein Projekt inspirierte [JohannesNE](https://github.com/JohannesNE/literature-clock) zu einer [Webversion](http://jenevoldsen.com/literature-clock/). Ich wieder rum wollte dies nutzen um mir bei jedem Shell Aufruf mir das passende Zitat zu der aktuellen Zeit anzeigen zu lassen. Daraus entstand [fortlit](https://github.com/xsteadfastx/fortlit). Ein kleines Python Script, welches man in die Shell seiner Wahl einbauen kann. Ich habe die Daten ein wenig gesäubert und ein schönes JSON daraus gebaut. Für die Einfachheit gibt es auch ein [PEX](https://github.com/pantsbuild/pex)-File. Viel Spaß!

```
If I was punctual in quitting Mlle. Reuter's domicile, I was at least equally punctual in arriving there; I came the next day at five minutes before two, and on reaching the schoolroom door, before I opened it, I heard a rapid, gabbling sound, which warned me that the "priere du midi" was not yet concluded.
- The Professor, Charlotte Brontë
```
