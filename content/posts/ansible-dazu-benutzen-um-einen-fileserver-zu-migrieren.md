Title: Ansible dazu benutzen um einen Fileserver zu migrieren
Date: 2015-06-17 10:44
Slug: ansible-dazu-benutzen-um-einen-fileserver-zu-migrieren
Tags: ansible, python


Ab und zu kommt es dann doch einmal vor das man seinen Fileserver umziehen muss. Diese Migration kann man gut benutzen um zum Beispiel mal ein paar Permissions gerade zu ziehen oder andere Kleinigkeiten anzupassen. Nun hatte ich mich dran gemacht ein Script zu schreiben mit allen Befehlen die ich dazu brauche. Wir kennen alle die Nachteile von schnell gehackten Bash-Scripten. Irgendwo ein Dreher drin und die Daten müssen aus dem Backup geholt werden oder man vergisst User oder Gruppen.

Ich werde immer mehr zum [Ansible](http://www.ansible.com/) Fan. Vor allem das strukturiere definieren von Tasks hilft mir sehr meine Aufgabe darzustellen. Ein weiterer Vorteil ist das Ansible sich um so Sachen wie "Errorhandling" kümmert und es auch möglich ist Results aus dem einem Task im anderen wieder aufzugreifen.

Hier passiert nichts wildes. Wir bereiten den neuen Fileserver vor mit allen Benutzern, Gruppen und den Files die wir benötigen. Dazu gibt es ein paar Tasks die die Permissions gerade ziehen während wir migrieren. Hier das Playbook was ich dafür geschrieben habe. Ich habe es versucht zu kommentieren.

**Update:** Ich habe einen kapitalen Fehler begangen. Ich habe zweimal eine Variabel mit dem Namen `task` registriert. Da die notifizierten Tasks erst am Ende ausgeführt werden, wird `task` einfach überschrieben. Jetzt haben beide Tasks zwei verschiedene Variabeln.

```
---
# Ich führe das ganze nicht remote aus sondern lokal.
#
- hosts: localhost
  sudo: yes

  tasks:

    - name: install rsync
      apt: name=rsync
           state=present

    # Hier legen wir zwei Gruppen an.
    #
    - name: add groups
      group: name={{ item }}
             state=present
      with_items:
        - intern
        - extern

    # Wir legen zwei Benutzer an. Die im Dict angegebenen Gruppen werden der
    # Gruppe "sambashare" hinzugefügt. Nichts besonderes. Die Benutzer
    # haben "/bin/false" als Shell und ein Homeverzeichnis in "/home"
    #
    - name: add users
      user: name={{ item.user }}
            state=present
            shell=/bin/false
            home=/home/{{ item.user }}
            groups=sambashare,{{ item.groups }}
            append=yes
      with_items:
        - { user: 'user1', groups: 'intern' }
        - { user: 'user2', groups: 'intern,extern' }

    # Ansible hat ein "synchronize"-Modul was ein Wrapper für Rsync ist.
    # Wirklich schön. So muss man nicht ein Script zusammen hacken sondern
    # kann die kompletten Möglichkeiten von Ansible zu nutzen.
    #
    # Wir speichern die Task-Results in der Variabel "task" damit wir sie in
    # den Handlern benutzen können. Ein Möglichkeit um zum Beispiel nur
    # die Permissions anzuwenden an das Item welches sich verändert hat.
    # Im Normalfall würde er bei nur einem geänderten Item die Handler laufen
    # lassen. Diese würden dann über alle Verzeichnisse rüber laufen und
    # die Permissions ändern. Da es sich um große Verzeichnisse handelt,
    # musste es eine bessere Lösung geben. Die Logik der Handler werden
    # später erklärt.
    #
    - name: sync freigaben
      synchronize: src=root@192.168.1.1:/srv/samba/{{ item.src }}/
                   dest=/srv/samba/{{ item.dest }}
                   perms=no
                   group=no
                   delete=yes
      with_items:
        - { src: 'Erstefreigabe', dest: 'erstefreigabe' }
        - { src: 'Zweitefreigabe', dest: 'zweitefreigabe' }
      register: freigaben
      notify:
        - set freigaben group
        - set freigaben file permissions
        - set freigaben group permissions
        - set freigaben permissions

    - name: sync homes
      synchronize: src=root@192.168.1.1:/home/{{ item }}/
                   dest=/home/{{ item }}
                   group=no
                   delete=yes
      with_items:
        - user1
        - user2
      register: homes
      notify:
        - set home group

  handlers:

    # Hier haben wir so einen Handler. Erstmal iteriert er über alle
    # Task-Results. Und nun kommt "when" ins Spiel: Er führt das Kommando
    # nur aus wenn ein Item als geändert gilt. So gibt es wenig Overhead
    # beim Ausführen der Handler. Sie werden nur ausgeführt wenn es auch
    # wirklich nötig ist.
    #
    - name: set freigaben group
      command: chgrp -R {{ item.item.dest }} /srv/samba/{{ item.item.dest }}
      with_items: freigaben.results
      when: item.changed == True

    - name : set freigaben file permissions
      command: find /srv/samba/{{ item.item.dest }} -type f -exec chmod 0664 {} \;
      with_items: freigaben.results
      when: item.changed == True

    - name : set freigaben group permissions
      command: find /srv/samba/{{ item.item.dest }} -type d -exec chmod 2775 {} \;
      with_items: freigaben.results
      when: item.changed == True

    - name: set freigaben permissions
      file: path=/srv/samba/{{ item.item.dest }}
            state=directory
            mode=2775
            owner=root
            group={{ item.item.dest }}
      with_items: freigaben.results
      when: item.changed == True

    - name: set home group
      command: chgrp -R {{ item.item }} /home/{{ item.item }}
      with_items: homes.results
      when: item.changed == True
```
