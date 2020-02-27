---
title: 'Flask Bootstrap Local '
slug: flask-bootstrap-local
tags:
- flask
- bootstrap
date: "2014-02-14T08:31:00+01:00"
author: marvin
draft: false
---

Ich arbeite gerade an einem Quiz-"Framework". Es ist primär für den Kunst-Unterricht meiner Frau. Und was man an den meisten Schulen ja immer noch nicht hat: Internetz. Deswegen war es wichtig das solche Sachen wie JavaScript und CSS lokal ausgeliefert werden und nicht online. Um das ganze schnell und ansehnlich zu gestalten, wollte ich Bootstrap nutzen. Noch kompfortabler geht das unter Flask mit Flask-Bootstrap. Einfach installieren und einknuppern. Schon gibt es eine Template-Base die man verwenden kann. Einziger offensichtlicher Nachteil war: JS und CSS kommen aus dem Netz. Aber ich lag falsch. Die Docs deuteten an das er auch Lokal ausliefern kann. Wie man das macht... muss man sich natürlich aus dem Code und Google zusammen suchen. Der Code verriet das es eine Config-Variabel mit dem Namen "BOOTSTRAP_SERVE_LOCAL" gibt. Noch ein wenig Suche und ich wusste dann wie ich sie vom Standard "False" auf "True" setzen konnte. 

	:::python
	app = Flask(__name__)
	app.config['BOOTSTRAP_SERVE_LOCAL'] = True
	Bootstrap(app)

Wäre ja zu einfach das so in die Docs zu schreiben ;-).