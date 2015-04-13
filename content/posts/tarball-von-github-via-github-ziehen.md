Title: Tarball von Github via curl ziehen 
Slug: tarball-von-github-via-github-ziehen 
Date: 2014-09-25 11:16
Tags: github, curl 

Schon was mich bei Sourceforge wahnsinning genervt hat: Es gab keinen schönen Link den man in wget werfen konnte um an sein Install-Paket zu kommen. Immer war da dieser Rattenschwanz an Mirror-Url-Zeug am Filename. Ich liebe es ja wenn es Seiten dazu optimiert sind schnell mal per Shell was auf den Computer laden zu können. Will man ein Tarball von GitHub saugt `curl` oder `wget` oft nur die Redirect-Website und nicht das eigentliche File. Ein großes meh. Wie lange ich gehscuat habe wie ich an den richtige Link komme. Bis sich rausstellte das ich vielleicht mal was an meinem `curl`-Aufruf ändern könnte.

	curl -LOk https://github.com/xsteadfastx/blog/archive/master.zip

Und es funktioniert. Ich kann mich immer nur selber ermahnen: RTFM!!1!!!!1!einself
