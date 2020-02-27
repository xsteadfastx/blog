FTP_HOST=xsteadfastx.org/
FTP_TARGET_DIR=/
FTP_USER=xstead_0
HUGO_VERSION=0.65.3
OUTPUTDIR=./public

clean:
	rm -rf public

build:
	hugo

install_deps:
	apk add --no-cache lftp git
	git clone -b v$(HUGO_VERSION) --depth 1 https://github.com/gohugoio/hugo.git /tmp/hugo
	(cd /tmp/hugo; go install)
	rm -rf /tmp/hugo

ftp_upload:
	lftp ftp://$(FTP_USER):$(FTP_PASS)@$(FTP_HOST) -e "set ssl:verify-certificate no; mirror -R --ignore-time --no-perms --parallel=4 -e --use-cache -v $(OUTPUTDIR) $(FTP_TARGET_DIR); quit"

ftp_upload_clean:
	lftp ftp://$(FTP_USER):$(FTP_PASS)@$(FTP_HOST) -e "set ssl:verify-certificate no; mirror -R --no-perms --parallel=4 -e -v $(OUTPUTDIR) $(FTP_TARGET_DIR); quit"

.PHONY: clean build install_deps ftp_upload ftp_upload_clean
