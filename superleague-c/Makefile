.PHONY: clean memcheck

superleague: superleague.c
	gcc -Wall -g -l jansson -o $@ $<

memcheck: superleague
	DEBUGINFOD_URLS='https://debuginfod.archlinux.org' valgrind --leak-check=full ./superleague data/super-league.json

clean:
	rm -f superleague