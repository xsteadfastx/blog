blog
====


## install ##
1. `git clone git@github.com:xsteadfastx/blog.git`
2. `cd blog && virtualenv -p /usr/bin/python3 venv`
3. `source venv/bin/activate`
4. `pip install -r requirements.txt`

## upgrade ##
`pip install --upgrade pelican markdown ghp-import shovel`

## write ##
1. put the markdown files in "content/posts"
2. test it with `make html && make serve` 
3. upload it to github with `make github`
