EMULATOR := sameboy
DEBUGGER := sameboy_debugger

build:
	@mkdir -p build
	rgbasm -i src src/*.asm -o build/built.o
	rgblink -o build/hello-world.gb build/built.o
	rgbfix -v -p 0 build/hello-world.gb

clean:
	rm -rf build/

run: build
	$(EMULATOR) build/hello-world.gb
	
debug: build
	$(DEBUGGER) build/hello-world.gb

