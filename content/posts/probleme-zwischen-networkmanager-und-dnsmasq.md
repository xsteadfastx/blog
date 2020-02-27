---
title: Probleme zwischen NetworkManager und dnsmasq
slug: probleme-zwischen-networkmanager-und-dnsmasq
tags:
- linux
- ubuntu
- dnsmasq
- networkmanager
date: "2015-10-08T14:14:00+02:00"
author: marvin
draft: false
---
Description: Komische DNS Timeouts

Neuer Wohnort und das Generve sein Netzwerk neu einzurichten. So betreibe ich einen kleinen [Raspberry Pi](https://de.wikipedia.org/wiki/Raspberry_Pi) der sich um mein VPN, DNS und DHCP kümmert. Für die beiden letzteren Dienste setze ich auf [dnsmasq](https://en.wikipedia.org/wiki/Dnsmasq). Ein ziemlich kleiner und Schlanker DNS und DHCP Server. Mein Problem was das es auf meinen Ubuntu Laptops immer wieder zu komische DNS Abfrage Problemen kam. Irgendwie wollte er manchmal Domains nicht richtig auflösen. Einfach nervig. Anscheinend gibt es ein Problem zwischen dem NetworkManager unter Ubuntu und dnsmasq. Der NetworkManager setzt dnsmasq selber auf dem Client ein um den Resolver zu stellen. Da scheint in manchen Fällen auch das Problem zu liegen. Was in meinem Fall geholfen hat: den NetworkManager so zu konfigurieren das er wieder normal die `/etc/resolv.conf` benutzt. Dazu editieren wir `/etc/NetworkManager/NetworkManager.conf` und kommentieren die Zeile `dns=dnsmasq` aus.