Title: virtualenv und Ubuntu Trusty Tahr 
Slug: virtualenv-und-ubuntu-trusty-tahr
Date: 2014-04-23 07:55
Tags: ubuntu, python

Eigentlich wollte ich ja nur mein ThinkPad upgraden. Die neue Ubuntu Version "Trusty Tahr" ist erschienen. Der Updateprozess lief soweit sauber durch und nach dem Reboot war viel weniger kaputt als sonst. Also schnell wieder ran ans coden. Mein virtualenv ging auf einmal nicht mehr. "Trusty Tahr" ist mit Python 3.4 gekommen, da schien das "Problem" zu sein. `virtualenv` wollte nicht mehr. Irgendeine komische Fehlermeldung. Ab Python 3 und vor allem mit 3.4 sollte man eigentlich das eigene `pyvenv` benutzen anstatt `virtualenv`. Dieses failed unter Ubuntu aber sowas von:

	$ pyvenv-3.4 foo
	Error: Command '['/home/mpreuss/foo/bin/python3.4', '-Im', 'ensurepip', '--upgrade', '--default-pip']' returned non-zero exit status 1

What the fizzle? Versucht man es mit `--without-pip` klappt es... aber immer extra pip per Hand installieren? Habe ich eigentlich keine Lust zu. Ich bin auch nicht [alleine](https://bugs.launchpad.net/ubuntu/+source/python3-defaults/+bug/1306114). Also eine Lösung musste her. Und die ist einfacher als ich dachte. 

Einfach per `pip install --upgrade virtualenv` virtualenv upgraden. Und schon kann man mit

	virtualenv -p /usr/bin/python3 foo

sich ein Python 3 Environment bauen. Ist zwar nur ein Workaround aber ich hatte eh immer `virtualenv` genommen.
