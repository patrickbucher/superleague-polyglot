.PHONY: all clean memcheck

all: superleague

.SUFFIXES: .c .o
.c.o:
	gcc -c -Wall -g -o $@ $<

superleague: superleague.o parsing.o
	gcc -Wall -g -l jansson -o $@ superleague.o parsing.o

memcheck: superleague
	DEBUGINFOD_URLS='https://debuginfod.archlinux.org' valgrind \
					--leak-check=full ./superleague data/super-league.json >/dev/null

clean:
	rm -f superleague *.o
