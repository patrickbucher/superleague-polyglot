defmodule TableRow do
  defstruct team: "",
            rank: 0,
            wins: 0,
            defeats: 0,
            ties: 0,
            goals_scored: 0,
            goals_conceded: 0,
            goals_difference: 0,
            points: 0

  def new(home_team, away_team, home_goals, away_goals) do
    from_result(home_team, away_team, home_goals, away_goals)
  end

  defp from_result(home_team, away_team, home_goals, away_goals) when home_goals > away_goals do
    [
      Map.merge(basic_row(home_team, home_goals, away_goals), %{wins: 1, points: 3}),
      Map.merge(basic_row(away_team, away_goals, home_goals), %{defeats: 1, points: 0})
    ]
  end

  defp from_result(home_team, away_team, home_goals, away_goals) when home_goals < away_goals do
    [
      Map.merge(basic_row(home_team, home_goals, away_goals), %{defeats: 0, points: 0}),
      Map.merge(basic_row(away_team, away_goals, home_goals), %{wins: 1, points: 3})
    ]
  end

  defp from_result(home_team, away_team, home_goals, away_goals) when home_goals == away_goals do
    [
      Map.merge(basic_row(home_team, home_goals, away_goals), %{ties: 1, points: 1}),
      Map.merge(basic_row(away_team, away_goals, home_goals), %{ties: 1, points: 1})
    ]
  end

  defp basic_row(team, our_goals, their_goals) do
    %TableRow{
      team: team,
      goals_scored: our_goals,
      goals_conceded: their_goals,
      goals_difference: our_goals - their_goals
    }
  end
end
