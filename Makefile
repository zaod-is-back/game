.PHONY: setup test build clean

setup:
	bash scripts/setup-codespace.sh

test:
	bash scripts/test-stop.sh

build:
	bash scripts/build-apk.sh

clean:
	rm -rf build dist
