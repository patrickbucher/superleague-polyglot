# SuperLeague in C

## Requirements

- C Toolchain (`build-essential` on Ubungu/Debian, `base-devel` on Arch)
- [jansson](https://jansson.readthedocs.io/en/latest/index.html)

## Run It

    make

    ./superleague data/super-league.json
    ./superleague data/challenge-league.json
    ./superleague data/sorting.json

## Code

- `superleague.c`: main program
- `parsing.c`: file reading and JSON parsing
	- `parsin.h`: header file
