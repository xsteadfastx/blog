Title: git-hook zum Push-Backup
Slug: git-hook-zum-push-backup
Date: 2015-01-16 14:09
Tags: git

Ich liebe git-hooks. Damit kann man von kleinen Tätigkeiten bis zum großen Rollout alles machen. Hier mal etwas kleines:

Wenn ich auf meiner Entwicklungs-Box einen commit mache, möchte ich das es sofort auf eine Backup-Box gepusht wird. Einfach nur den aktuellen Branch auf dem ich mich befinde auf einen Server unter dem gleichen Branchnamen. Dafür legt man unter `.git/hooks/` das File `post-commit` an. Der Inhalt sieht in diesem Fall so aus:

       git push backupbox $(git rev-parse --abbrev-ref HEAD)

Dann ein `chmod +x .git/hooks/post-commit` nicht vergessen und anfangen zu commiten. Läuft...
