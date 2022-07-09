{
    home_team = $1
    home_goals = $2
    away_team = $3
    away_goals = $4

    teams[home_team] = home_team
    teams[away_team] = away_team
    goals_scored[home_team] += home_goals
    goals_scored[away_team] += away_goals
    goals_conceded[home_team] += away_goals
    goals_conceded[away_team] += home_goals

    if (home_goals > away_goals) {
        wins[home_team]++
        defeats[away_team]++
    } else if (home_goals < away_goals) {
        wins[away_team]++
        defeats[home_team]++
    } else {
        ties[home_team]++
        ties[away_team]++
    }
}

END {
    for (i in teams) {
        printf("%s:%d:%d:%d:%d:%d:%d:%d\n",
            i, wins[i], ties[i], defeats[i],
            goals_scored[i], goals_conceded[i],
            goals_scored[i] - goals_conceded[i],
            wins[i] * 3 + ties[i])
    }
}
