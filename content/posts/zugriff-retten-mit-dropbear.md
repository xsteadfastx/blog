---
title: Zugriff retten mit Dropbear
slug: 'zugriff-retten-mit-dropbear '
tags:
- ssh
date: "2014-01-28T22:41:00+01:00"
author: marvin
draft: false
---

Was macht man eigentlich wenn man den SSHD auf einem Root-Server konfigurieren möchte, man aber doch ein wenig Angst hat das es das letzte mal ist den Server von innen zu sehen? Ich hatte mal auf Twitter rumgefragt und kam eigentlich zu einer brauchbaren Lösung. Als erstes ist es wohl so, dass die SSH-Session erhalten bleibt solange ich den Dienst nur "reloade". Das war mir dann aber doch ein wenig zu gefährlich. Der andere Plan: [Dropbear](https://de.wikipedia.org/wiki/Dropbear) installieren und auf einem alternativen Port laufen lassen. Dropbear ist ein schlanker kleiner SSH-Server. Schnell installiert, den Port angepasst und gestartet. Ich glaube ich kann jetzt doch ein wenig ruhiger schlafen.