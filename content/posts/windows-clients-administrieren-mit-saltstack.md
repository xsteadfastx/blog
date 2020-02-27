---
title: 'Windows Clients administrieren mit SaltStack '
slug: 'windows-clients-administrieren-mit-saltststack '
tags:
- saltstack
- windows
date: "2014-09-29T12:39:00+02:00"
author: marvin
draft: false
---
Das Leben ist nicht immer schön. Manchmal muss man sich auch um andere Systeme kümmern. Softwareupdates einspielen oder zum Debuggen sich kurz die Netzwerk-Konfiguration anzeigen lassen. Während meiner Ausbildung war es üblich das ich als Azubi 60-70 Computer ablaufen musste und überall zum Beispiel den Adobe Acrobat Reader updaten musste. Selbst ein WSUS wurde zu diesem Zeitpunkt noch nicht eingesetzt. Zur Zeit administriere ich eine Handvoll Linux Server und mehrere Windows 7 Clients. Um den Einsatz eines WSUS zu umgehen hatte ich eine Weile auf [WPKG](http://wpkg.org/) gesetzt. Das besteht aus einen Client der unter Windows beim Start und Runterfahren auf einer SMB-Freigabe lauscht auf der ein VBS-Script liegt. Und dann passiert irgendeine Art von "Magic". Die einzellnen Programme werden in ein, für mich, cryptischen XML-Files gepflegt. Meistens ist es ein kopfloses copy-pasten aus dem WPKG-Wiki. Meistens funktionierte es... manchmal aber auch nicht. 

In letzter Zeit las ich mehr über [Ansible](http://www.ansible.com). Ein Tool mit dem man viele Server gleichzeitig bespielen und administrieren kann. Gerade in Zeiten des [Heartbleed-Bugs](https://de.wikipedia.org/wiki/Heartbleed) ein Segen für viele Systemadministratoren. Die Anzahl der Server die ich administriere ist überschaubar. Die Anzahl der Windows-Clients ist doch an einem Punkt wo es nervt die ganzen Sicherheitsupdates einzupflegen. Problem: Ansible kann kein Windows. [SaltStack](http://www.saltstack.com/) schon. Auf SaltStack stieß ich duch meine Suche Ansible auf Windows Client laufen zu bekommen. Also schnell aufgesetzt... und siehe da... es läuft. Auf Windows wird ein kleiner Client installiert und den Rest machen Python-Scripte auf einem Linux-Server. Und da bin ich schon bei einem der Vorteile für mich: Es ist in Python geschrieben. Für die Templates wird [Jinja2](http://jinja.pocoo.org/) eingesetzt. Ich bin alles andere als ein Wahnnsinns-Programmierer aber trotzdem bin ich nicht ganz abgeneigt wenn es in einer Sprache geschrieben ist die ich ansatzweise, minimal verstehe. Für meine Windows-Files habe ich ein [Repo angelegt](https://github.com/xsteadfastx/salt-winrepo). Dort habe ich die Software die ich so jeden Tag auf meinem Windows Client brauche oder die gut ist um sie vorzuhalten. Man weiß ja nie. In den jeweiligen Verzeichnissen liegt eine `init.sls` und `files`. In `init.sls` sind die Anweisungen der Pakete zum installieren und deinstallieren. In `files` liegen die Setup-Files. Sehr praktisch da wir hinter einem Proxy sind und Windows da relativ oft Probleme hat aus dem Internet Files zu laden. Also kein hassle mit Samba oder dem Internet. Die `init.sls` für Firefox sieht bei mir wie folgt aus:     

```
firefox:
  32.0.3:
    installer: 'salt://win/repo/salt-winrepo.git/firefox/files/Firefox Setup 32.0.3.exe'
    full_name: 'Mozilla Firefox 32.0.3 (x86 de)'
    reboot: False
    install_flags: ' /s '
    uninstaller: 'C:\Program Files (x86)\Mozilla Firefox\uninstall\helper.exe'
    uninstall_flags: ' /S'
  32.0.2:
    installer: 'salt://win/repo/salt-winrepo.git/firefox/files/Firefox Setup 32.0.2.exe'
    full_name: 'Mozilla Firefox 32.0.2 (x86 de)'
    reboot: False
    install_flags: ' /s '
    uninstaller: 'C:\Program Files (x86)\Mozilla Firefox\uninstall\helper.exe'
    uninstall_flags: ' /S'
```

Eigentlich selbsterklärend. Für jede Version die ich anbiete lege ich einen neuen Abschnitt an. Darin wird festgelegt wo das Setup-File liegt und wie es "silent" installiert werden kann. Was natürlich auch praktisch ist: Wie es wieder deinstalliert werden kann. Das `salt://` spiegelt 

```
file_roots:
  base:
    - /srv/salt
```

in der `/etc/salt/master` wieder. In dem gleichen File gibt es auch noch einen Bereich für die Windows Software Repo settings:

```
#####     Windows Software Repo settings #####
##############################################
# Location of the repo on the master
win_repo: '/srv/salt/win/repo'

# Location of the master's repo cache file
win_repo_mastercachefile: '/srv/salt/win/repo/winrepo.p'

# List of git repositories to include with the local repo
win_gitrepos:
  - 'https://github.com/xsteadfastx/salt-winrepo.git'
```

Im unteren Abschnitt kann man noch externe Git-Repos hinzufügen die mit `salt-run winrepo.update_git_repos` geupdatet werden können. Der Windows Client ist relativ flott eingerichtet. Der Installationsdialog fragt nach dem Master. Ich habe in dem Firmen-DNS einfach den Host "salt" angelegt. Dieser zeigt auf den Master. Dann muss in Zukunft auch nichts an der Config geschraubt werden, sollte der Master mal seine Location ändern. Dann werden Keys zwischen Master und Minion (so nennt man die Clients) ausgetauscht. Diese müssen auf den Master mit `salt -A` akzeptiert werden. Los gehts:

Mit `salt-run winrepo.genrepo` wird das Cache-File aktualisiert. Nun muss es mit `salt '*' pkg.refresh_db` auf die Minions überspielt werden. Spricht man so zum Beispiel Debian/Ubuntu Systeme an, wird auf den Minions ein `apt-get update` ausgeführt. Da da Minions nun alle Informationen haben kann man Firefox mit `sudo salt '*' pkg.install firefox` installieren. Soll es eine bestimmte Version sein `sudo salt '*' pkg.install firefox version=32.0.3`. Und fertig ist die laube. Natürlich kann man auch States (`wininstall.sls`) anlegen. In diesem Fall eine Liste von Software die jeder Windows-Minion haben soll:

```
7zip:
  pkg.installed

adobeflash:
  pkg.installed

adobereader:
  pkg.installed

jre:
  pkg.installed

vlc:
  pkg.installed

firefox:
  pkg.installed

thunderbird:
  pkg.installed

jitsi:
  pkg.installed

keepass:
  pkg.installed
```

Dies kann ich mit `salt '*' state.sls wininstall` ausrollen.

Ein paar Beispiele was man noch so alles machen kann:

```
# Netzwerk Informationen der Minions
salt '*' network.interfaces

# Liste der installierten Software auf den Minions
salt '*' pkg.list_pkgs

# Liste der lokalen User
salt '*' ps.get_users
```

Also ich bin und bleibe Fan.