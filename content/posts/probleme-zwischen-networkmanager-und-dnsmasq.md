Title: Probleme zwischen NetworkManager und dnsmasq
Date: 2015-10-08 13:14
Slug: probleme-zwischen-networkmanager-und-dnsmasq
Tags: linux, ubuntu, dnsmasq, networkmanager
Description: Komische DNS Timeouts

Neuer Wohnort und das Generve sein Netzwerk neu einzurichten. So betreibe ich einen kleinen [Raspberry Pi](https://de.wikipedia.org/wiki/Raspberry_Pi) der sich um mein VPN, DNS und DHCP kümmert. Für die beiden letzteren Dienste setze ich auf [dnsmasq](https://en.wikipedia.org/wiki/Dnsmasq). Ein ziemlich kleiner und Schlanker DNS und DHCP Server. Mein Problem was das es auf meinen Ubuntu Laptops immer wieder zu komische DNS Abfrage Problemen kam. Irgendwie wollte er manchmal Domains nicht richtig auflösen. Einfach nervig. Anscheinend gibt es ein Problem zwischen dem NetworkManager unter Ubuntu und dnsmasq. Der NetworkManager setzt dnsmasq selber auf dem Client ein um den Resolver zu stellen. Da scheint in manchen Fällen auch das Problem zu liegen. Was in meinem Fall geholfen hat: den NetworkManager so zu konfigurieren das er wieder normal die `/etc/resolv.conf` benutzt. Dazu editieren wir `/etc/NetworkManager/NetworkManager.conf` und kommentieren die Zeile `dns=dnsmasq` aus.
