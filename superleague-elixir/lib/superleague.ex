defmodule SuperLeague do
  def create_table(matches) do
    Enum.map(matches, fn m ->
      TableRow.new(m["homeTeam"], m["awayTeam"], m["homeGoals"], m["awayGoals"])
    end)
    |> Enum.concat()
    |> Enum.map(&Map.from_struct/1)
    |> Enum.reduce(%{}, &combine_results/2)
    |> Map.values()
    |> Enum.sort_by(& &1[:team])
    |> Enum.sort_by(& &1[:wins])
    |> Enum.sort_by(& &1[:goals_difference])
    |> Enum.sort_by(& &1[:points])
    |> Enum.reverse()
    |> Enum.with_index(fn e, i -> Map.put(e, :rank, i + 1) end)
  end

  defp combine_results(result, table) do
    team = result.team

    if Map.has_key?(table, team) do
      combined = Map.merge(table[team], result, &merge/3)
      Map.put(table, team, combined)
    else
      Map.put(table, team, result)
    end
  end

  defp merge(key, left_value, right_value) do
    if key == :team do
      left_value
    else
      left_value + right_value
    end
  end

  def format_table(table) do
    title = %{
      team: "Team",
      rank: "#",
      wins: "w",
      defeats: "l",
      ties: "d",
      goals_scored: "+",
      goals_conceded: "-",
      goals_difference: "=",
      points: "P"
    }

    lines =
      Enum.map([title | table], fn e ->
        team = align_right(e[:team], 25)
        rank = align_right(e[:rank], 2)
        wins = align_right(e[:wins], 2)
        lost = align_right(e[:defeats], 2)
        ties = align_right(e[:ties], 2)
        g_pos = align_right(e[:goals_scored], 2)
        g_neg = align_right(e[:goals_conceded], 2)
        g_dif = align_right(e[:goals_difference], 2)
        points = align_right(e[:points], 2)
        "#{team} #{rank} #{wins} #{lost} #{ties} #{g_pos} #{g_neg} #{g_dif} #{points}"
      end)

    [title | entries] = lines
    sep = String.duplicate("-", String.length(title))
    Enum.join([title | [sep | entries]], "\n")
  end

  defp align_right(x, width) when is_number(x) do
    :string.right(String.to_charlist(Integer.to_string(x)), width)
  end

  defp align_right(x, width) do
    :string.right(String.to_charlist(x), width)
  end
end
