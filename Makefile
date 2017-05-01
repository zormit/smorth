all: forth forth.lst

ASMFLAGS+= -w+orphan-labels
ASMFLAGS+= -l forth.l
ASMFLAGS+= -g
forth.o: forth.asm
	nasm $(ASMFLAGS) -f elf $<

LDFLAGS+= --dynamic-linker /lib/ld-linux.so.2
LDFLAGS+= -lc
LDFLAGS+= -m elf_i386
forth: forth.o
	ld $(LDFLAGS) -o $@ $<

forth.lst: forth
	objdump -M intel -d $< > $@

clean:
	rm forth forth.o forth.lst forth.l -f
