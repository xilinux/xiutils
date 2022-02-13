CC=gcc
FLAGS=

DESTDIR=
PREFIX=/usr

.DEFAULT_GOAL := build

install: install-hbar install-colors install-parseconf install-shtests 
build: build-hbar 

install-headers: src/*.h
	install -m644 src/*.h ${DESTDIR}${PREFIX}/include

install-shtests: src/shtests
	install -m755 src/shtests.sh ${DESTDIR}${PREFIX}/bin/shtests

install-chroot: src/xichroot
	install -m755 src/xichroot.sh ${DESTDIR}${PREFIX}/bin/xichroot

install-parseconf: src/parseconf
	install -m755 src/parseconf.sh ${DESTDIR}${PREFIX}/bin/parseconf

install-hbar: build-hbar
	install -m755 bin/hbar ${DESTDIR}${PREFIX}/bin

install-colors: src/colors.list
	sh src/generate_colors.sh ${DESTDIR}${PREFIX} src/colors.list

check-parseconf: 
	shtests ./test/parseconf.sh


build-hbar: src/hbar.c install-colors
	mkdir -pv bin
	${CC} src/hbar.c -o bin/hbar ${FLAGS}

clean:
	rm -r bin
