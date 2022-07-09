# SuperLeague in AWK

## Requirements

- awk
- bash
- coreutils
- jq

## Run It

    ./superleague.sh < data/super-league.json
    ./superleague.sh < data/challenge-league.json
    ./superleague.sh < data/sorting.json

## Code

- `superleague.sh`: shell script
- `rows.awk`: computes the table
- `output.awk`: prints the table

Alternative:

- `single-file.sh`: same as above, just everything in a single file
