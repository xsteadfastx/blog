---
title: git-hook zum Push-Backup
slug: git-hook-zum-push-backup
tags:
- git
date: "2015-01-16T14:09:00+01:00"
author: marvin
draft: false
---
Ich liebe git-hooks. Damit kann man von kleinen Tätigkeiten bis zum großen Rollout alles machen. Hier mal etwas kleines:

Wenn ich auf meiner Entwicklungs-Box einen commit mache, möchte ich das es sofort auf eine Backup-Box gepusht wird. Einfach nur den aktuellen Branch auf dem ich mich befinde auf einen Server unter dem gleichen Branchnamen. Dafür legt man unter `.git/hooks/` das File `post-commit` an. Der Inhalt sieht in diesem Fall so aus:

       git push backupbox $(git rev-parse --abbrev-ref HEAD)

Dann ein `chmod +x .git/hooks/post-commit` nicht vergessen und anfangen zu commiten. Läuft...