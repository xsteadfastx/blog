blog
====

## create environment ##
1. `make writingenv`

## write ##
1. create new post with `make newpost`
2. write the post with`vim content/posts/new-blog-post.md`
3. upload with `make ftp_upload`

## resize images ##
1. `mogrify -resize "960x>" -strip -interlace Plane -quality 85% *`
