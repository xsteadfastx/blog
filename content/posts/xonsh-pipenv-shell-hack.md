---
title: 'xonsh: pipenv shell hack'
slug: xonsh-pipenv-shell-hack
tags:
- xonsh
- python
- pipenv
date: "2018-01-08T09:38:00+01:00"
author: marvin
draft: false
---
Ich benutze nun schon ein paar Monate [pipenv](http://pipenv.readthedocs.io/en/latest/). Dies macht das verwalten von Projekt-Virtualenvironments einfach. Das Programm handelt auch die Listen und Abhängigkeiten zu Library's die für das eigene Projekt gebraucht werden. Es erstellt automatisch ein Pipfile. Dies soll irgendwann mal auch für `pip` implementiert werden um die lästige `requirements.txt` abzulösen.

So schön so gut. Meine Shells sind mal wieder in heavy rotation und so bin ich von `zsh` zu `fish` wieder bei [xonsh](http://xon.sh) gelandet. Mir liegt einfach Python. Das Problem mit `pipenv` ist nun das, dass Kommando `pipenv shell` nicht mehr funktioniert. Das aktivieren von `virtualenvs` scheint vor allem für die klassischen Shells konzipiert zu sein. `xonsh` benutzt seine eigene Verwaltung für die virtuellen Umgebungen: [vox](http://xon.sh/python_virtual_environments.html). Da alles andere zu funktionieren scheint, habe ich mir einfach einen Alias geschrieben, der auf der offiziellen `pipenv`-Funktion zum finden von virtuellen Umgebungen beruht.

    :::python
    def _pipenv_shell(args, stdin=None):
        import base64
        import hashlib
        import os
        import re

        if args[0] == 'shell':
            print('WARNING: using own xonsh alias function instead of pipenv shell')
            name = $PWD.split(os.sep)[-1]
            sanitized = re.sub(r'[ $`!*@"\\\r\n\t]', '_', name)[0:42]
            hash = hashlib.sha256(os.path.join($PWD, 'Pipfile').encode()).digest()[:6]
            encoded_hash = base64.urlsafe_b64encode(hash).decode()
            venv_name = sanitized + '-' + encoded_hash
            for venv in $(ls $VIRTUALENV_HOME).splitlines():
                if venv == venv_name:
                    vox activate @(venv)
        else:
            ~/.local/bin/pipenv @(args)

Das füge ich dann dem `alias`-Dictionary hinzu:

    :::python
    aliases['pipenv'] = _pipenv_shell

Damit `pipenv` und `vox` das selbe Verzeichnis für die `virtualenvs` benutzen setze ich 

    :::python
    $VIRTUALENV_HOME = os.path.join(os.path.expanduser('~'), '.local/share/virtualenvs')

Ich hoffe das ich diese Krücke irgendwann nicht mehr brauche...