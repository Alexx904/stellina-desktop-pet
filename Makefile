.PHONY: all build run clean package

all: package

build:
	swift build

run:
	swift run

package:
	bash scripts/build_app.sh

clean:
	rm -rf .build build

