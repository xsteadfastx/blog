---
title: Python Programme ausrollen mit PEX
slug: python-programme-ausrollen-mit-pex
tags:
- python
- linux
date: "2017-11-30T11:37:00+01:00"
author: marvin
draft: false
---
Python hat mit vielen Vorurteilen zu kämpfen. Es sei langsam, nur komisches Gescripte, entweder zu dynamisch oder nicht dynamisch genug. Ein, zum Teil, verständlicher Vorwurf ist die Schwierigkeit des Ausrollens und Veröffentlichung von Paketen. Dem möchte ich nur zum Teil zustimmen. Als völliger Programmier-Noob tue ich es mir ab und zu wirklich schwer eine gute `setup.py` zu schreiben. Und muss ich dies tun, suche ich mich durch die verschiedensten Auswüchse meiner liebsten Python-Projekte auf GitHub. Was mir da immer hilft, ist das [Beispiel Projekt](https://github.com/pypa/sampleproject). Daran kann man sich wunderbar entlang hangeln. Dann steht das nächste Problem an. Wie veröffentliche ich das ganze am besten. Einerseits lädt man es bei [PyPI](https://pypi.org) hoch. Auf der Benutzerseite fragt man sich jedesmal wie man das Paket am besten installieren. Man möchte niemals `pip install` als `root` ausführen und das Paket einfach blind in den globalen Raum installieren. Es gibt `pip install --user foobar`. Dies installiert es zwar global aber nur im eigenen Home-Verzeichnis. Auch nicht so toll und es kann natürlich zu Abhängigkeitesproblemen kommen, so sehr diese Raum mit anderen Paketen wächst und immer mehr verwulstet. Zum entwickeln benutzt man immer `virtualenvs` um sich seine abgeschlossenen Umgebungen zu bauen. Als Anwender ist das auch ziemlich unschön diese zu managen und am Ende verliert man dann doch den Überblich. Es gibt da [pipsi](https://github.com/mitsuhiko/pipsi). Dieses kleine Tool nimmt das Umgebungs-Management in die Hand. Funktioniert ganz wunderbar. Doch noch gibt es ganz andere Problemherde. Was ist mit Abhängigkeiten die ein Kompilieren nötig haben? Immer mehr Sachen müssen installiert werden und am Ende klappt es zwar irgendwie, schön ist es aber nicht. Gerade wenn das Paket von normalen Endnutzern benutzt werden soll.

Neben Tools wie [pyinstaller](http://www.pyinstaller.org/) gibt es, das von Twitter entwickelte, [PEX](https://github.com/pantsbuild/pex). Dies macht sich zu eigen das Python Module aus Zip-Files importieren kann und Python wohl ziemlich vergibt was die Struktur von Zip-Files anbelangt. `pex` bastelt ein `virtualenv`, zippt es und knallt einen [Shebang](https://de.wikipedia.org/wiki/Shebang) vor das Zip. Nun ist es ausführbar und man benötigt nur noch einen passenden Python Interpreter, alles was zum ausführen gebraucht wird, befindet sich in dem Zip. Dies ist ein anderer Ansatz als Python und seine Abhängigkeiten in ein Gesammtpaket zu schnüren. Python wird weiterhin auf dem System gebraucht. `pex` unterstützt sogar mehrere Python Versionen und Plattformen in einem PEX-File.

Ich habe das ganze mal für mein kleines Tool [DoTheBackup](https://github.com/xsteadfastx/DoTheBackup) gemacht:

```
pex -e dothebackup.ui:main --python=python3.6 --python=python3.5 --python=python3.4 --python-shebang=/usr/bin/python3 -o dist/dothebackup-`uname -s`-`uname -m`.pex --no-wheel --disable-cache -v .
```

- `-e dothebackup.ui:main`: Dies ist der Entrypoint. Also die Funktion die ausgeführt wird, wenn das Programm ausgeführt wird. In diesem Fall eine [click](http://click.pocoo.org/) Funktion.
- `--python=python3.6`: Hier beschreibt man die Python Version für die das File gebaut wird. Das schöne: Man kann mehrere angeben.
- `--python-shebang=/usr/bin/python3`: Wir wollen es so universell halten wie möglich. Standardmäßig setzt `pex` hier die volle Version ein: `/usr/bin/python3.6`. Dies bringt uns aber nichts wenn es auch auf anderen Versionen laufen soll. `/usr/bin/python3` should do the trick.
- `-o dist/dothebackup-`uname -s`-`uname -m`.pex`: Dies beschreibt das Outputfile. In diesem Fall: `dothebackup-Linux-x86_64.pex`.
- `--no-wheel`: Dies habe ich gebraucht wegen irgendeinen Fehlers. Er benutzt zum bauen keine wheels.
- `--disable-cache`: `pip` benutzt keine Pakete aus dem Cache.
- `-v`: Verbose.
- `.`: Die Location.. also das aktuelle Verzeichnis.

Das bauen des PEX-Files lasse ich von [Travis](https://travis-ci.org/) machen. Dies in meinem ultimativen [Python Docker Image](https://hub.docker.com/r/xsteadfastx/tox-python/). Alles dazu findet ihr in dem [Repo](https://github.com/xsteadfastx/dothebackup).

Hier noch ein kleines Video das PEX erklärt:

{{< youtube NmpnGhRwsu0 >}}