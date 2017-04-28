all: forth

forth.o: forth.asm
	nasm -f elf $<

LDFLAGS+= --dynamic-linker /lib/ld-linux.so.2
LDFLAGS+= -lc
LDFLAGS+= -m elf_i386
forth: forth.o Makefile
	ld $(LDFLAGS) -s -o $@ $<

clean:
	rm forth forth.o
