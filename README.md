blog
====

## create environment ##
1. `git clone git@github.com:xsteadfastx/blog.git`
2. build the environment with `cd blog && vagrant up`
3. login in the environment with `vagrant ssh`

## write ##
1. create new post with `make newpost`
2. write the post with`vim content/posts/new-blog-post.md`
3. upload with `make ftp_upload`
