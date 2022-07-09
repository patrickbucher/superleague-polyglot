#!/bin/sh

jq -r '.[] | .homeTeam, .homeGoals, .awayTeam, .awayGoals' \
    | paste -d ',' - - - - \
    | awk -f rows.awk -F ',' \
    | sort -t ':' -k 8,8nr -k 7,7nr -k 2,2nr -k 1,1 \
    | awk -f output.awk -F ':'
