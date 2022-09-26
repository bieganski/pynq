.PHONY: build

all: build
	openFPGALoader --board pynq_z2 build/top.bit

clean:
	@rm -rf build

build: build/top.bit

build/top.bit: clean
	python3 wrapper.py

