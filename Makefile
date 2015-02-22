SHELL = /bin/sh
nasm = nasm
cc = gcc

binExt = ./binExt/
bin = ./bin/
src = ./src/
srcExt = ./srcExt/
res = ./resources/
anyPr = ./any\ progs/


all: $(bin)disk $(bin)start $(bin)sysfile $(binExt)filetrans $(bin)testprog
	dd if=$(bin)start of=$(bin)disk bs=512 count=1 conv=notrunc
	echo "start copied"

	$(binExt)filetrans $(bin)disk $(bin)sysfile
	echo "sysfile copied"

	$(binExt)filetrans $(bin)disk $(res)loglogo
	echo "loglogo copied"

	$(binExt)filetrans $(bin)disk $(bin)testprog
	echo "testprog copied"

	$(binExt)filetrans $(bin)disk $(anyPr)wsg
	echo "wsg copied"

$(binExt)cdisk:
	$(cc) $(srcExt)createdisk.c -o $(binExt)cdisk

$(bin)disk: $(binExt)cdisk
	$(binExt)cdisk
	mv disk $(bin)

$(bin)start:
	$(nasm) -f bin -i $(src) $(src)start.asm -o $(bin)start

$(bin)sysfile:
	$(nasm) -f bin -i $(src) $(src)startOS.asm -o $(bin)sysfile

$(bin)testprog:
	$(nasm) -f bin -i $(src) $(src)testprog.asm -o $(bin)testprog

$(binExt)filetrans:
	$(cc) $(srcExt)filetrans.c -o $(binExt)filetrans

clean:
	rm -f $(bin)*
	rm -f $(binExt)*

run:
	qemu-system-i386 $(bin)disk