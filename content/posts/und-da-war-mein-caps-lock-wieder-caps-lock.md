---
title: "Und da war mein Caps Lock wieder Caps Lock"
date: 2020-03-16T11:45:19+01:00
slug: und-da-war-mein-caps-lock-wieder-caps-lock
tags:
  - linux
  - systemd
  - capslock
draft: false
---

Ich habe über Umwegen eine ziemlich schöne, kleine CHERRY Tastertur (ML4400) zugesteckt bekommen. Eins der Vorteile ist in manchen Fällen auch ein Nachteil: Es gibt keine Windows Taste. Nichts das ich jemals stolz darauf war diese auf meiner Tastertur zu haben. Ich erinnere mich daran das man für CHERRY Tasterturen sogar einen [Ersatz mit TUX](https://www.keyboardco.com/product/tux-penguin-logo-windows-keys-2-keycaps-for-cherry-mx-switches.asp) bekam. Nun nutze ich seit vielen vielen Jahren [i3](https://i3wm.org) als WindowManager und nutze die Windows Taste um viele Shortcuts darin auszuführen. Mein Musclememory ist komplett darauf konditioniert. Will ich meine neue Tastertur also benutzen, muss ich in irgendeine Richtung umdenken. Caps Lock wollte ich eh schon immer mal wegmappen. Also was solls.

        setxkbmap -option caps:super

Funktioniert bis auf mein halbes Abbrechen meiner Finger und dem Entgegenarbeiten des gut trainierten Muskelspeichers. Ich fing an zu arbeiten, klappte irgendwann den Laptop zu und am nächsten Tag wunderte ich mich, dass nichts mehr so wahr wie ich es wollte. Kommt heraus: Nachdem Suspend sind die Einstellungen weg. Wenig rumgegoogelt und auf was gestoßen. Es gibt das Verzeichnis `/lib/systemd/system-sleep`. Darin kann man Scripte stecken die beim Einschlafen oder Aufwachen ausgeführt werden. Dabei übergibt systemd zwei Argumente bei jedem Suspend: 1. `pre` oder `post` und 2. die Action sowie `suspend` oder `hibernate`. Mein Script sieht wie folgt aus:

{{< highlight shell >}}
        #!/bin/sh
        case $1/$2 in
            pre/*)
                echo "Going to $2..."
                ;;
            post/*)
                setxkbmap -option super:caps
                ;;
        esac
{{< / highlight >}}

Wichtig wäre es vielleicht auch wo genau das Script rein kommt. Dies findet man schnell mit `systemctl help systemd-suspend.service` heraus.
