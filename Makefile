.PHONY: help up debug down check

help:
	@echo "make up      connect in the background (needs ~/.config/gpclient-wrappers/config)"
	@echo "make debug   connect in the foreground to see gpclient output"
	@echo "make down    disconnect"
	@echo "make check   syntax-check the scripts"

up:
	bin/gp-connect

debug:
	bin/gp-connect --foreground

down:
	sudo gpclient disconnect

check:
	bash -n bin/gp-connect bin/gp-firefox
	sh -n bin/gp-dns-script
	@command -v shellcheck >/dev/null && shellcheck bin/gp-connect bin/gp-firefox bin/gp-dns-script || true
