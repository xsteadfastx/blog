Title: xonsh aus Bash heraus starten
Date: 2016-07-29 14:39
Slug: xonsh-aus-bash-heraus-starten
Tags: xonsh, python, linux

Noch ein kleiner Nachtrag zu dem [Artikel]({filename}/posts/meine-neue-shell-xonsh.md) von gestern. Heute wollte ich mal wieder in meiner Blogging Vagrant Docker Box alles auf den neusten stand bringen. Ich benutze dazu `vagrant provision`. Dies startet das Provisioning, also holt meine neuen Config-Files. installiert neue Software usw. Ansible benutzt SSH um auf die Vagrant Box zuzugreifen und dies war auf einmal ein Problem. Ansible lief sofort an die Wand.

    /bin/sh: sudo -H -S -n -u root /bin/sh -c 'echo BECOME-SUCCESS-mtobhjchhszgqaaixzbsbsolwbuprmhn; LANG=de_DE.UTF-7 LC_ALL=de_DE.UTF-8 LC_MESSAGES=de_DE.UTF-8 /usr/bin/python /home/vagrant/.ansible/tmp/ansible-tmp-1469778394.25-104576843898387/apk; rm -rf \"/home/vagrant/.ansible/tmp/ansible-tmp-1469778394.25-104576843898387/\" > /dev/null 2>&1' && sleep 0: not found\r\n

Loggte ich mich ein und führe das Ansible Playbook manuell aus, kein Problem. Ich hatte xonsh als Login Shell eingerichtet und da läuft etwas schief. SSH ruft den Befehl per `exec` auf und da hat xonsh noch ein paar Probleme. Es gibt den Shell Befehl `exec` und die Python-Funktion `exec`. Diese sind schwierig zu unterscheiden und schon läuft es schief. Es wird an einem Fix gearbeitet. Der soll auch in den nächsten Tagen released werden. Bis dahin habe ich mich dazu entschieden meine Login-Shell wieder auf Bash umzustellen und daraus dann xonsh zu starten. Dazu benutze ich das File `~/.profile`. Dies ist dafür da Sachen beim Login auszuführen. Aber nur wenn es `~/.bash_profile` und `~/bash_login` nicht gibt. Ich erweitere also `~/.profile`.

    [ -f /usr/local/bin/xonsh ] && exec /usr/local/bin/xonsh

Wenn es `/usr/local/bin/xonsh` gibt dann führe es aus. Nun geht erstmal wieder alles. Ein Workaround... aber was solls?
