PREFIX ?= /usr/local

install:
	cp -f bin/release-ghub-pypi $(PREFIX)/bin

uninstall:
	rm -f $(PREFIX)/bin/release-ghub-pypi

