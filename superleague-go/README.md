# SuperLeague in Go

## Requirements

- [Go](https://go.dev/) (v1.17.6)

## Run It

Windows:

    go build -o superleague.exe main/superleague.go

    ./superleague.exe data/super-league.json
    ./superleague.exe data/challenge-league.json
    ./superleague.exe data/sorting.json

Linux:

    go build -o superleague main/superleague.go

    ./superleague data/super-league.json
    ./superleague data/challenge-league.json
    ./superleague data/sorting.json

## Code

- `main/superleague.go`: main entry point
- `table.go`: logic
