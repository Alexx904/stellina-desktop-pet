.PHONY: all build run clean package package-windows run-windows

all: package

build:
	swift build

run:
	swift run

package:
	bash scripts/build_app.sh

package-windows:
	powershell -ExecutionPolicy Bypass -File scripts/build_windows.ps1

run-windows:
	python Sources/Windows/main.py

clean:
	rm -rf .build build
