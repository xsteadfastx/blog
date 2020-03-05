HUGO_VERSION=0.65.3
OUTPUT_DIR=./public

clean:
	rm -rf public

build:
	hugo
	mkdir public/feed
	cp public/index.xml public/feed/index.html

install_deps:
	apk add --no-cache lftp git
	GO111MODULE=on go get -v -u github.com/gohugoio/hugo@v$(HUGO_VERSION)

ftp_upload:
	rclone sync $(OUTPUT_DIR) blog://

.PHONY: clean build install_deps ftp_upload
