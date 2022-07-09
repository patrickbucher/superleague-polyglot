#!/usr/bin/python

import json

from numpy.random import choice

teams = [
    'FC Basel 1893',
    'FC Zürich',
    'BSC Young Boys',
    'Grasshopper Club Zürich',
    'FC Lugano',
    'Servette FC',
    'FC St. Gallen 1879',
    'FC Sion',
    'FC Luzern',
    'FC Lausanne-Sport',
]

def random_goals():
    possibilities = [0, 1, 2, 3, 4, 5]
    probabilities = [0.25, 0.25, 0.2, 0.15, 0.1, 0.05]
    return int(choice(possibilities, 1, p=probabilities)[0])

if __name__ == '__main__':
    games = []
    played = {t: 0 for t in teams}
    games_completed = 0
    rounds = 4

    for r in range(rounds):
        for t, team in enumerate(teams):
            for opponent in teams[t+1:]:
                played[team] += 1
                played[opponent] += 1
                if r % 2:
                    home_team, away_team = team, opponent
                else:
                    away_team, home_team = team, opponent
                home_goals = random_goals()
                away_goals = random_goals()

                print(f'{home_team:>24s} {home_goals:1d}:{away_goals:1d} {away_team:24s}')

                games.append({
                    'homeTeam': home_team,
                    'awayTeam': away_team,
                    'homeGoals': home_goals,
                    'awayGoals': away_goals,
                })

    for played in played.values():
        assert played == (len(teams) - 1) * rounds

    with open('league.json', 'w') as json_file:
        json_file.write(json.dumps(games, ensure_ascii=False))

    empty_ranking = {
        'name': None,
        'position': None,
        'goals_scored': 0,
        'goals_received': 0,
        'goals_diff': 0,
        'wins': 0,
        'draws': 0,
        'losses': 0,
        'points': 0,
    }
    rankings = {t: dict(empty_ranking) for t in teams}
    for game in games:
        home_team = game['homeTeam']
        away_team = game['awayTeam']
        home_goals = game['homeGoals']
        away_goals = game['awayGoals']
        home = rankings[home_team]
        away = rankings[away_team]
        home['goals_scored'] += home_goals
        home['goals_received'] += away_goals
        away['goals_scored'] += away_goals
        away['goals_received'] += home_goals
        home['goals_diff'] = home['goals_scored'] - home['goals_received']
        away['goals_diff'] = away['goals_scored'] - away['goals_received']
        if home_goals > away_goals:
            home['wins'] += 1
            home['points'] += 3
            away['losses'] += 1
        elif home_goals < away_goals:
            home['losses'] += 1
            away['wins'] += 1
            away['points'] += 3
        else:
            home['draws'] += 1
            home['points'] += 1
            away['draws'] += 1
            away['points'] += 1

    assert sum([r['goals_diff'] for r in rankings.values()]) == 0

    for k, v in rankings.items():
        v['name'] = k
    rankings = sorted(rankings.values(), key=lambda r: (r['points'], r['goals_diff']), reverse=True)
    print(f'{"Name":>25s} {"#":>2s} {"w":>2s} {"d":>2s} {"l":>2s} {"+":>2s} {"-":>2s} {"=":>3s} {"P":>2s}') 
    print('-' * 50)
    for i, r in enumerate(rankings):
        r['position'] = i + 1
        print(f'{r["name"]:>25s} {r["position"]:2d} ' + \
              f'{r["wins"]:2d} {r["draws"]:2d} {r["losses"]:2d} ' + \
              f'{r["goals_scored"]:2d} {r["goals_received"]:2d} {r["goals_diff"]:3d}' + \
              f'{r["points"]:3d}')
