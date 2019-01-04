Title: pyhashwall 
Slug: pyhashwall
Date: 2014-03-31 16:08
Tags: twitter, socketsio, flask, javascript 


![pyhashwall]({static}/images/pyhashwall.png)

Ich hänge ganz schön hinter her. Nebenbei sind ein paar kleinere Projekte entstanden und ich hatte kaum Zeit darüber zu bloggen. Die wilde Fahrt geht weiter um ein wenig das Programmieren zu lernen. Da ich nun schon ein paar Sachen mit Flask gemacht habe, wollte ich sehen wie ich "Echtzeit"-Stuff damit realisieren kann. Mal gegoogelt und auf [Flask-SocketIO](https://github.com/miguelgrinberg/Flask-SocketIO) gestossen. Eine [Socket.IO](http://socket.io/) Integration für Flask. Noch nie etwas zuvor damit gemacht. Nur ab und zu gelesen. Vor JavaScript habe ich erstmal einiges an Respekt. Immer wenn ich was einbauen musste, war ich froh das es lief. Erklären oder verstehen konnte ich es nicht wirklich. Mittlerweile komme ich Schritt für Schritt dahinter (also die einfachen Sachen). Also brauchte ich ein Projekt. Wo sind eigentlich die ganzen Tweetwalls hin? Wenn man mit seinem Freunden eine Runde "Tatort" schaut und lustige Tweets lesen will. Und es wurde geboren: die [pyhashwall](https://github.com/xsteadfastx/pyhashwall). Dank dem Python-Modul [tweepy](https://github.com/tweepy/tweepy) kann man auf den Twitter-Stream zugreifen und so nach Hashtags ausschau halten, Bilder zwischenspeichern und das ganze per socketio auf die Seite "pushen". Gestern habe ich das ganze mal mit #tatort getestet. Lief...
