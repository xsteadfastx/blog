Title: Ansible, win_package und Upgrades
Date: 2016-04-12 12:15
Slug: ansible-win-package-und-upgrades
Tags: ansible, windows, linux

{% giphy b5TmEXrjZ2II8 %}

Das Ansible Modul [win_package](https://docs.ansible.com/ansible/win_package_module.html) beruht auf die Annahme das die `product_id` in der Registry vorhanden ist oder eben nicht. Davon macht es abhängig ob ein Paket installiert werden soll oder ob es schon vorhanden ist. Nun kann es ja auch vorkommen das man ein Paket, obwohl es laut Registry schon instaliert ist, es noch einmal installieren möchte. Quasi ein Upgrade machen. Schön wäre es wenn er nicht nur schaut ob das Paket installiert ist, sondern auch die installierte Version. Daran könnte man Task Entscheidungen treffen. Dies mache ich nun manuell. Ein Beispiel für VLC:

```
---

# Der ganz normale Install-Task. Es wird nach der product_id gesucht gegebenenfalls installiert
- name: install
  win_package:
    product_id="VLC media player"
    path="//myserver/updates/software/vlc/vlc-2.2.2-win32.exe"
    arguments="/L=1031 /S"

# Ein Powershell Snippet das die Version des installierten Pakets in der Variabel "version" speichert
- name: check version
  raw: (Get-ItemProperty "HKLM:\SOFTWARE\wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\VLC media player").DisplayVersion
  register: version

- name: upgrade
  win_package:
    product_id="VLC media player upgrade" # Muss anders sein damit das Paket nochmal installiert wird
    path="//myserver/updates/software/vlc/vlc-2.2.2-win32.exe"
    arguments="/L=1031 /S"
  register: upgrade_results # Speichert das Ergebnis des Tasks in die Variabel "upgrade_results"
  changed_when: '"was installed" in upgrade_results.msg' # Ändert den Status auf "changed" wenn der String "was installed" im Ergebnis ist
  failed_when: '"was installed" not in upgrade_results.msg' # Status "failed" wenn "was installed" nicht im Ergebnis ist
  ignore_errors: True # Sonst bricht er ab bevor der Task überhaupt die Variabel "upgrade_results" befüllt
  when: '"2.2.2" not in version.stdout_lines' # Den Task nur ausführen wenn die Version eine andere ist
```
