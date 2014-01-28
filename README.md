blog
====


## install ##
`sudo pip install pelican markdown ghp-import shovel`

## upgrade ##
`sudo pip install --upgrade pelican markdown ghp-import shovel`

## write ##
* put the markdown files in "content/posts"
* create the static files with `pelican -s pelicanconf.py`
* put the stuff in the ghp-pages branch with `gh-import output`
* push with `git push origin gh-pages`

## test ##
* `cd output`
* `python -m SimpleHTTPServer 8000`
