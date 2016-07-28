Title: Meine neue Shell: xonsh
Date: 2016-07-28 16:47
Slug: meine-neue-shell-xonsh
Tags: python,xonsh,linux

Manchmal macht man Sachen die man selber nicht so wirklich versteht. Zum Beispiel hatte ich mich lange quer gestellt [ZSH](https://de.wikipedia.org/wiki/Zsh) einzusetzen. Wieso eine alternative Shell? BASH ist doch sowas wie ein standard auf den Servern auf denen ich arbeite. Vor ein paar Jahren dann die erste Installation. Total abgeschreckt von der Konfiguration (bin bis Heute nicht dahinter gekommen wie das alles funktioniert), war mir [oh-my-zsh]() ein Steigbügelhalter in die Welt von ZSH. Es ist eine Paket aus verschiedenen Plugins und Konfigurationen die das erste ZSH-Erlebnis, instant, beeindruckend gestaltet. Irgendwann war es mir zu langsam und ich stieg um auf [prezto](https://github.com/sorin-ionescu/prezto). Hat sich alles ein wenig flotter angefühlt und ich habe noch weniger verstanden was da im Hintergrund abläuft. Ja, man sollte sich die Sachen genauer anschauen und dann wäre es auch kein Problem. Aber manchmal fehlt mir Zeit weil ich meine Nase in tausend anderen Projekten habe. Es soll einfach funktionieren und the world a better place machen tun... oder zumindest meinen Alltag.

Nun bin ich auf einen Beitrag auf der PyCon über [xonsh](http://xon.sh) gestossen.

{% youtube uaje5I22kgE %}

Es ist eine alternative Shell die in Python geschrieben ist und das Bindeglied zwischen Shell und Python sein möchte. Und das beste: Endlich eine Syntax in der Shell die ich mir merken kann. Nie wieder nachschauen wie `if` oder `for` in Bash funktionieren. "Nie wieder" ist ein harter Ausdruck. Selbst ich installiere xonsh nicht auf all meinen Servern. Es setzt Python 3.4 oder 3.5 voraus.

Bevor ich ein paar Anwendungsbeispiele nenne, möchte ich auf mein Setup hinweisen. Auf [GitHub](https://github.com/xsteadfastx/batcave) befinden sich meine Ansible Roles um meine Rechner einzurichten. Unter anderen auch [xonsh](https://github.com/xsteadfastx/batcave/tree/master/roles/xonsh).

## Python und Shell Kommandos gemeinsam nutzen

Hier ein Beispiel für ein xonsh-Script das den Output von allen Docker-Commands nimmt und den Output in Files schreibt. Dies habe ich gebraucht um meine xonsh Extension [xonsh-docker-tabcomplete](https://github.com/xsteadfastx/xonsh-docker-tabcomplete) zu testen. Ein Completer für Docker Kommandos die auch direkt auf die Docker-API zugreift. Danke [docker-py](https://github.com/docker/docker-py) und Python als Shell.


    :::python
    """Ein xonsh-Script um alle `--help` Outputs als Textfiles
    abzuspeichern.
    """
    import os
    import re

    # `parser` ist ein Modul mit ein paar Regex Parsern.
    from docker_tabcomplete import parser

    # Regex um Versionsnummer zu finden.
    RE_VERSION = re.compile(r'((?:\d+\.)?(?:\d+\.)?(?:\*|\d+))')

    # Hier nutze ich das erste mal ein wenig xonsh Magic.
    # Das `$()` macht genau das gleiche wie in Bash-Scripten. Es führt
    # Ein Kommando aus aus gibt den Output zurück. In diesem Fall den
    # Output von `docker --version` und sucht in Python per Regex nach
    # der Versionsnummer.
    DOCKER_VERSION = re.search(RE_VERSION, $(docker --version)).group(1)

    # Es wird ein Verzeichnis für die Docker Version angelegt falls es noch
    # nicht existiert.
    if not os.path.exists('../tests/data/{}'.format(DOCKER_VERSION)):
        os.makedirs('../tests/data/{}'.format(DOCKER_VERSION))

    # `parser.commands` nimmt den Output von `docker --help` und parst
    # nach allen Docker Kommandos. Wieder muss nicht mit `subprocess`
    # gefummelt werden sondern wir nutzen einfach `$()` von xonsh um
    # an den Output zu gelangen.
    COMMANDS = parser.commands($(docker --help))

    # Jetzt wird sogar Python mit Shell mit Python gemischt.
    for command in COMMANDS:
        with open('../tests/data/{}/{}.stdout'.format(DOCKER_VERSION, command), 'w') as f:

            # Es wird die Python-Variabel `command`, die gerade in benutzung ist,
            # in das Shell-Kommando `docker ... --help` eingefügt. Magic.
            f.write($(docker @(command) --help))


Dieses Script speichert man als `create_test_data.xsh` und kann es mit `xonsh create_test_data.xsh` ausführen.

## Meine `~/.xonshrc`

Yeah, endlich eine Shell Konfiguration in Python...


    import os
    import shutil

    from xonsh.environ import git_dirty_working_directory


    # XONSH ENVIRONMENT VARIABLES ############

    # Die Environment Variabeln werden wie Python Variabeln definiert.
    # Hier einige Beispiele. Diese sind vor allem um das Verhalten von
    # xonsh anzupassen.

    # xonsh supportet die bestehenden bash completion files.
    # Zumindestens die meisten. Ich hatte Probleme mit dem
    # Docker-Completion File und habe deswegen mein eigenes geschrieben.
    $BASH_COMPLETIONS = ['/etc/bash_completion.d', '/usr/share/bash-completion/completions']

    $CASE_SENSITIVE_COMPLETIONS = False
    $SHELL_TYPE = 'best'
    $SUPPRESS_BRANCH_TIMEOUT_MESSAGE = True
    $VC_BRANCH_TIMEOUT = 5
    $XONSH_COLOR_STYLE = 'monokai'

    # OTHER ENVIRONMENT VARIABLES ############
    $EDITOR = 'vim'
    $PYTHONIOENCODING = 'UTF-8'
    $LC_ALL = 'C.UTF-8'
    $SSL_CERT_FILE = '/etc/ssl/certs/ca-certificates.crt'

    # ALIASES ################################

    # Aliase sind in einem dict gespeichert das einfach erweitert werden kann.

    aliases['exec'] = aliases['xexec']
    aliases['ll'] = 'ls -la'
    aliases['tmux'] = 'tmux -2'

    # Jetzt wird es spannend: Wir können Funktionen oder Lambdas als
    # Aliase definieren. Hier der Fall das Mosh eine bestimmte
    # Environment Variabel gesetzt haben muss.
    def _alias_mosh(args, stdin=None):
        """A function to use as alias to get mosh running.

        There is a strange problem with mosh and xonsh. I have to set $SHELL to
        /bin/bash before running it. It should work with this little hack.
        """
        os.environ['SHELL'] = '/bin/bash'
        args.insert(0, 'mosh')
        cmd = ' '.join(args)
        os.system(cmd)

    aliases['mosh'] = _alias_mosh

    # GIT ####################################
    $FORMATTER_DICT['branch_color'] = lambda: ('{BOLD_INTENSE_RED}'
                                               if git_dirty_working_directory(include_untracked=True)
                                               else '{BOLD_INTENSE_GREEN}')

    # PATH ###################################

    # Die Path Variabel ist eine Liste die ich einfach extende.
    $PATH.extend(
        [
            $HOME + '/.local/bin',
            $HOME + '/miniconda3/bin',
            $HOME + '/node_modules_global/bin'
        ]
    )

    # XONTRIB ################################

    # Hier habe ich ein paar Erweiterungen enabled. Bei manchen schaue ich
    # ob der Befehl auf denen sie beruhen überhaupt da und einsatzfähig ist
    # bevor ich sie anschalte. Was nützt mir `apt-get` wenn ich nicht auf
    # einem Debian/Ubuntu System bin oder Docker nicht installiert ist?
    # Dies teste ich mit `shutil.which`.
    xontrib autoxsh vox_tabcomplete

    if shutil.which('apt-get'):
        xontrib apt_tabcomplete

    if shutil.which('docker'):
        xontrib docker_tabcomplete


## Ein wenig Rescue

Natürlich kann alles noch ein wenig buggy sein. Einmal gab es Probleme mit den Schreibrechten auf dem History-File und ich konnte kein Terminal mehr öffnen oder mich einloggen. Was da helfen kann: Per SSH und anderer Shell draufschalten und die Shell ändern.

    ssh meinuser@meinrechner sh


## Fazit

Das ist natürlich nur ein Bruchteil der Möglichkeiten und Sachen die man ausprobieren kann. Es ist ein Anfang und bis jetzt bin ich begeistert. Also einfach mal das Youtube Video anschauen und ausprobieren. Muss ja nicht gleich die Standard-Shell werden wie bei mir ;-).
