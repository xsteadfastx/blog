Title: Als git den ganzen Raspi Speicher frass
Slug: als-git-den-ganzen-raspi-speicher-frass
Date: 2015-01-13 10:14
Tags: git, raspberrypi

Ich experimentiere gerade rum um einen Raspberry Pi zu einer kleinen Jenkins-Testbox umzubauen. Ich weiß ich weiß... der Raspi ist nicht gerade eine Powermaschine. Trotzdem ist es ein Projekt in das ich gerade viel Zeit stecke. Plan ist es auf dem Raspi alle meine git-Repos zu haben und bei commits dann die Tests auszuführen. Gerade versuche ich per Jenkins ein MySQL Backup über git einzuspielen. Der Dump ist ganze unglaubliche 10 MB groß. Dies scheint zu reichen um git an seine Grenzen auf dem Raspi zu zeigen. Das ganze spiegelte sich in dieser Fehlermeldung wieder:

	remote: Counting objects: 666, done.
	remote: warning: suboptimal pack - out of memory
	remote: fatal: Out of memory, malloc failed

Ich konnte es beseitigen in dem ich in dem Remote-Repo folgendes machte:

	git config pack.windowMemory 10m
	git config pack.packSizeLimit 20m
