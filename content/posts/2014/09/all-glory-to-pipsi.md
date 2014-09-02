Title: All glory to pipsi 
Slug: all-glory-to-pipsi 
Date: 2014-09-01 15:25
Tags: python 

Mein "Code"-Ordner sieht ganz schön zerfurcht aus. Alles voll mit Virtual-Environments. Das funktioniert schon alles ganz gut zum entwickeln. Möchte ich aber Tools wie [beets](https://github.com/sampsyo/beets) oder [youtube-dl](https://github.com/rg3/youtube-dl) installieren und nutze dafür `pip`, haut er mir einfach alle Abhängigkeiten in den systemweiten Bereich. Schöner wäre es alles seperat in Virtuelenvs im Home-Verzeichnis zu haben. Nun kommt [pipsi](https://github.com/mitsuhiko/pipsi) ins Spiel: 

```
What does it do?  pipsi is a wrapper around virtualenv and pip
which installs scripts provided by python packages into separate
virtualenvs to shield them from your system and each other.

In other words: you can use pipsi to install things like
pygmentize without making your system painful.
```

Das erklärt eigentlich alles ganz schön. Alle Abhängigkeiten schön lokal im Home-Verzeichnis. Ich installier es mit einem 

	curl https://raw.githubusercontent.com/mitsuhiko/pipsi/master/get-pipsi.py | python 

und passe PATH soweit an, dass `~/.local/bin` bedacht wird. Mit 

	pipsi install beets 

installiert pipsi alles sauber so das ich es einfach mit 

	pipsi uninstall beets 

wieder loswerden könnte. Yiha. Dahinter steckt ma wieder mitsuhiko. Bekannt aus Projekten wie "flask", "jinja2", "click", usw... Was ein Teufelskerl. 
