Title: Ansible Playbooks und variable Hosts
Date: 2016-02-18 10:23
Slug: ansible-playbooks-und-variable-hosts
Tags: ansible, python, linux

Ich benutze [Ansible](http://ansible.com/) für viele Sachen. Unter anderem habe ich ein [Set an Playbooks und Roles](https://github.com/xsteadfastx/batcave) um meine Server so anzupassen das ich mich auf ihnen wohl fühle. Bis jetzt habe ich immer Ansible auch auf den Servern installiert und es dann lokal ausgeführt. Aber dabei nutze ich nicht das eigentlich Ansible Feature: das Ganze Remote über SSH auszurollen. Problem: In den Playbooks muss es die Zeile `- hosts:` geben. Aber eigentlich will ich das alles Variabel ausführen können. Zum Beispiel nutze ich die gleichen Files auch um meine Vagrant Container einzurichten. Wieso also beim Aufruf die Hosts dem Playbook nicht einfach übergeben? Die [Lösung](https://github.com/k4ml/importerror/blob/master/posts/ansible-playbook-specify-hosts-on-the-command-line.md) ist dann doch wieder einmal einfacher als man denkt. Man benutzt die Möglichkeit in Playbooks und Roles Variabeln einzusetzen.

```
---
- hosts: "{{ hosts }}"
  roles:
    - git
    - tmux
    - vim
    - zsh
```

Diese Variabel übergeben wir beim Aufruf von Ansible.

`ansible-playbook base.yml --extra-vars="hosts=myservers"`
