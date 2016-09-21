Title: semantic-ui und webpack
Date: 2016-09-21 14:57
Slug: semantic-ui-und-webpack
Tags: javascript, semanticui, webpack

{% giphy rR0ELLMF09bUI %}

Hier bin ich, der mega Java Script, CSS Webentwickler. Ich habe vor vielen Jahren aufgegeben überhaupt ansatzweise CSS zu verstehen. Danke Google und viel Copy-Pasta komme ich damit auch irgendwie über die runden. Verstehen tue ich fast nichts. Noch schlimmer ist JavaScript für mich. Ich habe auch sonst nicht die riesige Programmiererfahrung und fühle mich in meiner kleinen Python-Welt ziemlich wohl. Es gibt aber Projekte an denen kommt man nicht darum herum ein wenig Webkram zu erledigen.

Ich habe mich dafür entschieden diese kleine Firmenseite mit [Lektor](https://www.getlektor.com) zu bauen. Ein CMS, gebaut in Python, das statisches HTML generiert und wahnsinnig flexibel mit den Datenstrukturen ist. Man kann Datenmodele anlegen für bestimmte Arten von Seiten die wiederum vorgefertigte Elemente besitzen. Ich habe eine weile gebraucht und bin zum Fan geworden. Und stimmten die Datenmodelle kommt man schnell an den Punkt an dem es keinen Spaß macht: Die Templates. Versteht mich nicht falsch, die Templatesprache [Jinja2](http://jinja.pocoo.org/docs/dev/) ganz wunderbar. Es ist HTML, CSS und JavaScript das mich regelmäßig gehirnfurzen läßt. Welche Frameworks setzt man ein? Im Endeffekt ist man beim erstem import schon veraltet und verpasst immer den letzten heißen Scheiß. Die Seite wanderte von [purecss](http://purecss.io/) über [Bootstrap](http://getbootstrap.com/) zu [Semantic UI](http://semantic-ui.com/). Nun habe ich in den Docs von Lektor von [webpack](https://www.getlektor.com/docs/guides/webpack/) erfahren. Die Beschreibung auf der [offizielle Website](https://webpack.github.io/) hat mich noch mehr in die Verzweifelung getrieben. Aber wenn ich es nun richtig verstanden habe generiert er statische Assets und kann die Files kleiner machen. Man wirft ihm sein JavaScript (mit allen Abhängikeiten) und sein CSS (mit allen Abhängigkeiten) hin und er generiert ein JS und ein CSS daraus. Dies funktioniert mit manchen Frameworks besser und mit manchen weniger. Semantic-UI scheint da so seine [Probleme](https://github.com/Semantic-Org/Semantic-UI/issues/3533) zu haben. Hier also der Weg der für mich funktioniert hat.

Meine `webpack.config.js`:

    :::javascript
    var webpack = require('webpack');
    var path = require('path');
    var ExtractTextPlugin = require('extract-text-webpack-plugin');


    var options = {
      entry: {
        'app': './js/main.js',
        'styles': './scss/main.scss'
      },
      output: {
        path: path.dirname(__dirname) + '/assets/static/gen',
        filename: '[name].js'
      },
      devtool: '#cheap-module-source-map',
      resolve: {
        modulesDirectories: ['node_modules'],
        extensions: ['', '.js']
      },
      module: {
        loaders: [
          {
            test: /\.js$/,
            exclude: /node_modules/,
            loader: 'babel-loader',
            query: {
              presets: ['es2015'],
            }
          },
          {
            test: /\.scss$/,
            loader: ExtractTextPlugin.extract('style-loader', 'css-loader!sass-loader')
          },
          {
            test: /\.css$/,
            loader: ExtractTextPlugin.extract('style-loader', 'css-loader')
          },
          {
            test: /\.(woff2?|ttf|eot|svg|png|gif)(\?.*?)?$/,
            loader: 'file'
          }
        ]
      },
      plugins: [
        new webpack.optimize.UglifyJsPlugin({
          compress: {
            warnings: false
          }
        }),
        new webpack.optimize.DedupePlugin(),
        new webpack.optimize.OccurenceOrderPlugin(),
        new webpack.ProvidePlugin({
          $: 'jquery',
          jQuery: 'jquery'
        }),
        new ExtractTextPlugin('styles.css', {
          allChunks: true
        })
      ]
    };

    module.exports = options;

Ich habe alle Komponenten die ich von Semantic-UI brauche separat installiert:

`npm install -save-dev semantic-ui-css semantic-ui-sidebar semantic-ui-transition semantic-ui-visibility`

Dann habe ich alle CSS files in meine `/scss/main.scss` importiert:

```
@import "~semantic-ui-css/components/reset.css";
@import "~semantic-ui-css/components/site.css";
@import "~semantic-ui-css/components/container.css";
@import "~semantic-ui-css/components/grid.css";
@import "~semantic-ui-css/components/header.css";
@import "~semantic-ui-css/components/image.css";
@import "~semantic-ui-css/components/menu.css";
@import "~semantic-ui-css/components/divider.css";
@import "~semantic-ui-css/components/dropdown.css";
@import "~semantic-ui-css/components/segment.css";
@import "~semantic-ui-css/components/button.css";
@import "~semantic-ui-css/components/list.css";
@import "~semantic-ui-css/components/icon.css";
@import "~semantic-ui-css/components/sidebar.css";
@import "~semantic-ui-css/components/transition.css";
@import "~slick-carousel/slick/slick.css";
```

Alles anderen Versuche dies über meine `/js/main.js` zu machen, gelangen mir nicht. Alle möglichen `require('semantic-ui-css/components/reset.css')` wollten es einfach nicht tun. Als `@import` in der `/scss/main.scss` war es kein Problem. Nun kommen wir zum JavaScript. Normalerweise reicht ein `require('meinetollejslib')` und webpack hangelt sich durch die files und macht damit Sachen. Nur mit den Komponenten von Sematic wollte es nicht wirklich. Woran es genau lag weiß ich auch nicht so recht. Hat wohl was mit der Mondphase und rechtsdrehenden Joghurts zu tun. Die Lösung fand ich dann doch in einem [Bugreport](https://github.com/Semantic-Org/Semantic-UI/issues/3533). Hier meine `/js/main.js`:

```
import $ from 'jquery'
$.fn.sidebar = require('semantic-ui-sidebar')
$.fn.transition = require('semantic-ui-transition')
$.fn.visibility= require('semantic-ui-visibility')
```

Auf einmal kann ich die jquery Funtionen nutzen. Hexenwerk.
