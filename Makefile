OUTPUT_DIR=./public
FTP_HOST=xsteadfastx.org
FTP_USER=xstead_0

clean:
	rm -rf public

build:
	hugo
	mkdir public/feed
	cp public/index.xml public/feed/index.html

docker:
	docker build -t quay.io/xsteadfastx/blog - < Dockerfile

push: docker
	docker push quay.io/xsteadfastx/blog

ftp_upload:
	rclone sync -v --size-only $(OUTPUT_DIR) blog:/

rclone_config:
	echo "[blog]" > ~/.config/rclone/rclone.conf
	echo "type = sftp" >> ~/.config/rclone/rclone.conf
	echo "host = $(FTP_HOST)" >> ~/.config/rclone/rclone.conf
	echo "user = $(FTP_USER)" >> ~/.config/rclone/rclone.conf
	echo "pass = $(FTP_PASS)" >> ~/.config/rclone/rclone.conf

slurp_mentions:
	$(eval TOKEN := $(shell stty -echo; read -p "Token: " token; stty echo; echo $$token))
	curl "https://webmention.io/api/mentions?token=$(TOKEN)"|python -mjson.tool > data/mentions.json
	sed -i 's/https:\/\/xsteadfastx.org/http:\/\/localhost:1313/g' data/mentions.json

new_note:
	$(eval NOTE := notes/$(shell date +%Y%m%d%H%M).md)
	hugo new $(NOTE)
	nvim content/$(NOTE)


.PHONY: clean build docker push install_deps ftp_upload rclone_config slurp_mentions new_note
