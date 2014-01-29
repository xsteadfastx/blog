Title: ssl und ngircd
Slug: ssl-und-ngircd
Date: 2014-01-29 11:34 


Es kam die Idee auf für das Team einen IRC-Channel aufzumachen. Einfach um sich besser koordinieren zu können. Da gibt es natürlich zwei Möglichkeiten: Wir benutzen einfach [Freenode](http://freenode.net/) oder wir setzen was eigenes auf mittles [ngircd](http://ngircd.barton.de/). Da ich das eh immer schonmal machen wollte, viel die Wahl auf Möglichkeit Nummer Zwei. Bis jetzt ist alles super einfach gehalten. Channels werden erstmal nur über die Config definiert und der Server spricht SSL only. 

Erstmal irgendwie ein self-signed-el-billo Zertifikat erstellt:

	:::bash
	certtool --generate-privkey --bits 2048 --outfile server-key.pem
	certtool --generate-self-signed --load-privkey server-key.pem --outfile server-cert.pem
	certtool --generate-dh-params --bits 4096 --outfile dhparams.pem

Dann haben ich die ngird.conf zusammen geknuppert:

	:::bash
	[GLOBAL]
		Name = blubb.site 
		AdminInfo1 = Foo
	 	AdminInfo2 = Bar
		AdminEMail = marvin@blubb.site
		Info = IRC Server
		Listen = ::,0.0.0.0
		MotdFile = /etc/ngircd/ngircd.motd
		MotdPhrase =
		Password = 
		PidFile = /var/run/ngircd/ngircd.pid
		Ports = 
		ServerGID = irc
		ServerUID = irc

	[LIMITS]
		ConnectRetry = 60
		MaxConnections = 500
		MaxConnectionsIP = 10
  		MaxJoins = 10
  		MaxNickLength = 9
  		PingTimeout = 120
  		PongTimeout = 20

	[OPTIONS]
  		AllowRemoteOper = no
	  	ChrootDir = 
	  	CloakHost = 
	  	CloakUserToNick = no
	  	ConnectIPv4 = yes
	  	ConnectIPv6 = yes
	  	DNS = yes
	  	MorePrivacy = no
	  	NoticeAuth = no
	  	OperCanUseMode = yes
	  	OperServerMode = no
	  	PredefChannelsOnly = yes
	  	RequireAuthPing = no
	  	ScrubCTCP = no
	  	SyslogFacility = local1
	  	WebircPassword = 

	[SSL]
	  	CertFile = /etc/ngircd/server-cert.pem
	  	DHFile = 
	  	KeyFile = /etc/ngircd/server-key.pem
	  	KeyFilePassword = 
	  	Ports = 6667

	[CHANNEL]
	  	Name = #it
	  	Modes = n
	  	Key = 
	  	MaxUsers = 0
	  	Topic = Ecclesia IT
	  	KeyFile = 

Ich habe die "Ports" in "[GLOBAL]" auskommentiert und dafür nur die Ports in "[SSL]" stehen. Das sollte Verbindungen nur über SSL erlauben. Desweiteren können nur die per Config definierten Channels benutzt werden. Das macht die Zeile "PredefChannelsOnly = yes".

Das nächste Problem was sich mir in den wegstellte, war das selbstsignierte Zertifkat und weechat. Der mochte sich einfach nicht verbinden. Nicht schön aber "/set irc.server.blubb.ssl_verify off" half.

Alles noch recht simpel. Läuft aber. 
