#!/usr/bin/env ruby

require "json"

class Table
  def initialize(matches)
    rows = []
    matches.each do |m|
      hg = m["homeGoals"].to_i
      ag = m["awayGoals"].to_i
      rows << TableRow.new(m["homeTeam"], hg, ag)
      rows << TableRow.new(m["awayTeam"], ag, hg)
    end
    table = {}
    rows.each do |r|
      if table.key?(r.team)
        table[r.team].merge(r)
      else
        table[r.team] = r
      end
    end
    rows = table.values
    rows.sort_by! { |r| [-r.points, -r.goals_difference, -r.wins, r.team] }
    for i in 1..rows.length
      rows[i-1].rank = i
    end
    @table_rows = rows
  end
  def format()
    lines = []
    title_fmt = "%25s %2s %2s %2s %2s %2s %2s %3s %2s"
    row_fmt = "%25s %2d %2d %2d %2d %2d %2d %3d %2d"
    title_line = title_fmt % ["Team", "#", "w", "l", "d", "+", "-", "=", "P"]
    lines << title_line
    lines << "-" * title_line.length
    @table_rows.each do |r|
      lines << row_fmt % [r.team, r.rank, r.wins, r.defeats, r.ties,
                          r.goals_scored, r.goals_conceded, r.goals_difference,
                          r.points]
    end
    return lines.join("\n")
  end
end

class TableRow
  attr_accessor :team, :rank, :wins, :defeats, :ties,
    :goals_scored, :goals_conceded, :goals_difference, :points
  def initialize(team, goals_scored, goals_conceded)
    @team = team
    @rank = -1
    @goals_scored = goals_scored
    @goals_conceded = goals_conceded
    @goals_difference = goals_scored - goals_conceded
    if goals_scored > goals_conceded
      @wins = 1
      @defeats = 0
      @ties = 0
      @points = 3
    elsif goals_scored < goals_conceded
      @wins = 0
      @defeats = 1
      @ties = 0
      @points = 0
    else
      @wins = 0
      @defeats = 0
      @ties = 1
      @points = 1
    end
  end
  def merge(other)
    @goals_scored += other.goals_scored
    @goals_conceded += other.goals_conceded
    @goals_difference += other.goals_difference
    @wins += other.wins
    @defeats += other.defeats
    @ties += other.ties
    @points += other.points
  end
end

matches_file = File.open(ARGV[0])
matches_data = matches_file.read
matches = JSON.parse(matches_data)
table = Table.new(matches)
puts table.format()
