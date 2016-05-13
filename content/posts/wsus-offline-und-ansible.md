Title: WSUS Offline und Ansible
Date: 2016-05-13 12:52
Slug: wsus-offline-und-ansible
Tags: ansible, windows

Ansible ist schon sehr nice. Benutzt man es mit Windows, ist es auch noch nice aber manchmal fühlt man sich dabei wie ein Ritt auf einem Vulkan, durch die Hölle... oder sowas. Meist funktioniert es aber was im Hintergrund passiert gleicht Feen-Magie.

Da wir es wagen einen Proxy zu benutzen scheint es völlig unmöglich zu sein an Windows Updates zu kommen. Und in letzter Zeit scheinen auch meine Workarounds nicht zu fruchten. Immer wieder hängen die Updates tagelang in der Pipeline und können nicht runtergeladen oder installiert werden. Also schaute ich mir mal wieder einen alten Bekannten an: [WSUS Offline Update](http://www.wsusoffline.net/). Ein Paket aus Scripten das Updates zentral runterlädt und dann offline installiert werden kann. Das schöne daran: Das Download-Script liegt auch in Shell vor und kann so direkt auf dem Linux Samba Server ausgeführt werden. Nur wie kommen die Updates auf die Clients? Wie immer lautet die Antwort: Per Ansible Playbook:

```
---
- name: mount updates share and run update
  raw: "net use U: \\\\meinsambaserver\\updates /persistent:no; cmd /c U:\\wsusoffline\\client\\cmd\\DoUpdate.cmd"
  register: command_result
  changed_when: "'Installation successful' in command_result.stdout"
  failed_when:
    - "'Nothing to do!' not in command_result.stdout"
    - "'Installation successful.' not in command_result.stdout"
```

WSUS Offline liegt dabei auf einem `Updates`-Share. Die zwei schwierigsten Sachen war das Escaping der Orte für den Kommandoaufruf und den richtigen Status erkennen. Aus irgendeinem Grund hat WSUS Offline immer den Return Code 1 raus wenn er was installiert hat. Mit der Hilfe von `changed_when` und `failed_when` suche ich in dem STDOUT-Output nach bestimmten Stichworten um den richtigen Status zu bekommen. Bestimmt decke ich nicht alles ab, aber in meinen ersten Tests funktioniert es.
