Title: Prosody mit LDAP 
Slug: prosody-mit-ldap
Date: 2014-03-18 13:27
Tags: prosody, xmpp, ldap, cyrus


Ich stehe auf [Prosody](http://prosody.im) als XMPP Server. Ich habe schon etliche XMPP-Server angeschaut und eingesetzt: [jabberd](https://jabberd.org/), [ejabberd](http://www.ejabberd.im/) und [openfire](http://www.igniterealtime.org/projects/openfire/). Mein privater Server behaust nur mich und vielleicht ab und zu ein Bot. Dafür war mir ejabberd immer ein wenig zu viel und zu aufgeblasen. Vor 4-5 Jahren wurde mir Prosody empfohlen. Ein kleiner Server geschrieben in [Lua](http://www.lua.org/). Ich hatte noch nie etwas mit Lua gemacht, aber die Config von Prosody war echt übersichtlich und so war der Server innerhalb ein paar Minuten online. Die Userdaten brauchten auch keine Datenbank, sondern werden in Textfiles geschrieben. Vor allem für eine handvoll User sollte dies kein Problem sein. Auch wenn ich auf der Arbeit von Openfire zu Prosody wechseln wollte, fehlte mir der einfache LDAP-Support. Bei Openfire geht dies wirklich flott, inklusive Shared Roster die er sich per Gruppen aus LDAP holt. Openfire ist ein in Java geschriebens Biest. Zwar hatte ich bis jetzt nicht viele Probleme, aber extra Java auf dem Server zu installieren, gerade wenn es ein vserver ist, wollte ich nicht. Für dieses neue Projekt musste Prosody LDAP verstehen. Also mich mal dran gemacht. 

Erstmal lua-cyrussasl installieren:

       sudo apt-get install liblua5.1-cyrussasl0

Dann legen wir die passende sasl-config, unter `/etc/sasl/prosody.conf` an:

	pwcheck_method: saslauthd
	mech_list: PLAIN
	
Wir müssen unter `/etc/default/saslauthd` einstellen LDAP zu benutzen:

	MECHANISMS="ldap"

Und LDAP unter `/etc/saslauthd.conf` konfigurieren:

	ldap_servers: ldap://localhost
	ldap_search_base: ou=user,dc=foobar,dc=de

Ich musste den user `prosody` noch der Gruppe `sasl` hinzufügen. Nach einem Neustart des Dienstes kann man SASL testen:

	testsaslauthd -u username -p password

Läuft es müssen wir noch Prosody konfigurieren. Dazu wird die Variabel `authentication` angepasst:

	authentication = "cyrus"
	cyrus_service_name = "xmpp"	

Neustarten und es kann getestet werden. Nun bleibt noch das Problem mit dem Shared Roster. Was automatisches habe ich bis jetzt noch nicht gefunden. Ich kann mir aber vorstellen mal ein Script dafür zu schreiben. Kann ja nicht so schwierig sein. In der `prosody.conf` muss man das Modul `groups` auskommentieren (dies sollte natürlich runtergeladen worden sein und um richtigen Verzeichnis liegen) und die Shared-Liste defininieren:

	groups_file = "/etc/prosody/sharedroster.txt"

Dieses sind dann so aus:

	[it-Team]
	foo@bar.com
	bla@bar.com

So wie ich das sehe, können nur User vom selbigen Server eingetragen werden. Prosody neustarten und es sollte funktionieren.
