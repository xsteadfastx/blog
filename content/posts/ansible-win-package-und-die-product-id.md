---
title: Ansible, win_package und die product_id
slug: ansible-win-package-und-die-product-id
tags:
- ansible
- windows
date: "2016-04-08T12:55:00+02:00"
author: marvin
draft: false
---
Gerade läuft das letzte Windows 7 auf Windows 10 Update. Diese Möglichkeit habe ich genutzt um für die Administration der Clients von [SaltStack](http://saltstack.com) zu [Ansible](http://ansible.com) zu wechseln. Windows Administration ist für mich eher so ein leidiges Thema, was mich ziemlich oft auf die Palme bringt. Ansible benutze ich auf den Linux Servern für fast alles. Mal schnell ein paar Update einspielen oder auch für das ausrollen meines [batcaves](https://github.com/xsteadfastx/batcave).

## Master vorbereiten

Neben Ansible sollte man noch das Modul `pywinrm` installieren:

`pip install "pywinrm>=0.1.1"`

## Clients vorbereiten

Um Ansible unter Windows zu benutzen muss ein [PowerShell Script](https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1) ausgeführt werden. Damit dies funktioniert muss erst eine PowerShell Policy angepasst werden. Dies tut man mit `set-executionpolicy remotesigned`. Danach Script ausführen und alles sollte eingerichtet sein.

## Inventory

Auch die hosts-Datei muss ein wenig angepasst werden. Es werden ein paar zusätzliche Daten benötigt. Wenn das hosts-File so aussieht:

```
[windows]
192.168.1.5
192.168.1.6
192.168.1.7
```

habe ich eine `group_vars/windows.yml` angelegt die so aussieht:

```
ansible_user: winadminuser
ansible_password: winadminpassword
ansible_port: 5986
ansible_connection: winrm
ansible_winrm_server_cert_validation: ignore
```

Dieses File kann man mit `ansible-vault encrypt group_vars/windows.yml` verschlüßeln.

## Der erste Test

`ansible windows -m win_ping --ask-vault-pass` sollte für einen ersten Versuch reichen.

## Pakete installieren

Hier ein einfaches Beispiel um ein ein Paket zu installieren:

```
---
- name: Install the vc thingy
  win_package:
    name="Microsoft Visual C thingy"
    path="http://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe"
    Product_Id="{CF2BEA3C-26EA-32F8-AA9B-331F7E34BA97}"
    Arguments="/install /passive /norestart"
```

Ich hatte mit fast allen Paketen Probleme die `product_id` herauszufinden. Erst dachte ich es handelt sich hierbei um den Titel der Software in den Systemeinstellungen unter Windows. Pustekuchen. Man muss sich diese ID aus den Registry popeln. Diese befindet sich unter `HKLM:\Software\microsoft\windows\currentversion\uninstall`. Aber die sah bei mir ziemlich dünn aus und war bei weiten nicht mit allen Sachen gefüllt die ich installiert hatte. Stellt sich herraus das ein Teil der Registry sich unter `HKLM:\Software\wow6432node\microsoft\windows\currentversion\uninstall` versteckt. Und zwar wenn es sich um 32bit Pakete handelt.