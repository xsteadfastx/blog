HUGO_VERSION=0.65.3
RCLONE_VERSION=1.51.0
OUTPUT_DIR=./public
FTP_HOST=xsteadfastx.org
FTP_USER=xstead_0

clean:
	rm -rf public

build:
	hugo
	mkdir public/feed
	cp public/index.xml public/feed/index.html

install_deps:
	apk add --no-cache git gcc musl-dev
	GO111MODULE=on go get -v github.com/gohugoio/hugo@v$(HUGO_VERSION)
	GO111MODULE=on go get -v github.com/rclone/rclone@v$(RCLONE_VERSION)

ftp_upload:
	rclone sync --progress --size-only $(OUTPUT_DIR) blog:/

rclone_config:
	echo "[blog]" > ~/.config/rclone/rclone.conf
	echo "type = sftp" >> ~/.config/rclone/rclone.conf
	echo "host = $(FTP_HOST)" >> ~/.config/rclone/rclone.conf
	echo "user = $(FTP_USER)" >> ~/.config/rclone/rclone.conf
	echo "pass = $(FTP_PASS)" >> ~/.config/rclone/rclone.conf


.PHONY: clean build install_deps ftp_upload rclone_config
