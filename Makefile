.PHONY: help up run reconnect down status check

help:
	@echo "make up         connect in the background (GP_PORTAL or a config file, see README)"
	@echo "make run        connect in the foreground to see gpclient output"
	@echo "make reconnect  disconnect, then connect again (stuck, or new settings)"
	@echo "make down       disconnect"
	@echo "make status     show connection, tunnel address and DNS routing"
	@echo "make check      syntax-check the scripts"

up:
	bin/gp-connect

run:
	bin/gp-connect --foreground

reconnect:
	bin/gp-connect --reconnect

down:
	sudo gpclient disconnect

status:
	@bin/gp-status || true

check:
	bash -n bin/gp-connect bin/gp-firefox bin/gp-status
	sh -n bin/gp-dns-script
	@command -v shellcheck >/dev/null && shellcheck bin/gp-connect bin/gp-firefox bin/gp-status bin/gp-dns-script || true
