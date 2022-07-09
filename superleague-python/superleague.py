#!/usr/bin/env python3

import json
import sys


def create_table(json_file_path):
    with open(sys.argv[1], 'r') as f:
        data = f.read()
        matches = json.loads(data)

    rows = {}

    for result in matches:

        homeTeam = result['homeTeam']
        awayTeam = result['awayTeam']
        homeGoals = result['homeGoals']
        awayGoals = result['awayGoals']

        if homeTeam not in rows:
            rows[homeTeam] = new_row(homeTeam)
        if awayTeam not in rows:
            rows[awayTeam] = new_row(awayTeam)

        rows[homeTeam]['goalsScored'] += homeGoals
        rows[homeTeam]['goalsConceded'] += awayGoals
        rows[awayTeam]['goalsScored'] += awayGoals
        rows[awayTeam]['goalsConceded'] += homeGoals

        if homeGoals > awayGoals:
            rows[homeTeam]['wins'] += 1
            rows[awayTeam]['defeats'] += 1
        elif homeGoals < awayGoals:
            rows[awayTeam]['wins'] += 1
            rows[homeTeam]['defeats'] += 1
        else:
            rows[homeTeam]['ties'] += 1
            rows[awayTeam]['ties'] += 1

    for row in rows.values():
        row['goalsDifference'] = row['goalsScored'] - row['goalsConceded']
        row['points'] = row['wins'] * 3 + row['ties']

    rows = rows.values()
    rows = sorted(rows, key=lambda r: r['team'])
    rows = sorted(rows, key=lambda r: r['wins'], reverse=True)
    rows = sorted(rows, key=lambda r: r['goalsDifference'], reverse=True)
    rows = sorted(rows, key=lambda r: r['points'], reverse=True)

    for i, row in enumerate(rows):
        row['rank'] = i + 1

    return rows


def new_row(team):
    return {
        'team': team,
        'rank': 0,
        'wins': 0,
        'ties': 0,
        'defeats': 0,
        'goalsScored': 0,
        'goalsConceded': 0,
        'goalsDifference': 0,
        'points': 0,
    }

def output_table(rows):
    print('                     Name  #  w  d  l  +  -   =  P')
    print('--------------------------------------------------')
    for row in rows:
        print(f'{row["team"]:>25s} {row["rank"]:>2d} ' +\
              f'{row["wins"]:>2d} {row["ties"]:>2d} {row["defeats"]:>2d} ' +\
              f'{row["goalsScored"]:>2d} {row["goalsConceded"]:>2d} {row["goalsDifference"]:>3d} ' +\
              f'{row["points"]:>2d}')


if __name__ == '__main__':
    table = create_table(sys.argv[1])
    output_table(table)
