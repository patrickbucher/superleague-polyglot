# SuperLeague in Elixir

## Requirements

- [Elixir](https://elixir-lang.org/) (v1.13.0)

## Run It

    mix start data/super-league.json
    mix start data/challenge-league.json
    mix start data/sorting.json

## Code

- `lib/mix/tasks/start.ex`: main task
- `lib/superleague.ex`: building the table from the match results
- `lib/tablerow.ex`: table row for a single match result
