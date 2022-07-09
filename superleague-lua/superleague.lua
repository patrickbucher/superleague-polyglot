#!/usr/bin/env lua

local json = require("dkjson")

function new_league_row(team_name)
    return {team = team_name, wins = 0, ties = 0, defeats = 0, goals_scored = 0, goals_conceded = 0}
end

function sort(a, b)
    if a["points"] > b["points"] then
        return true
    elseif a["points"] < b["points"] then
        return false
    elseif a["goals_difference"] > b["goals_difference"] then
        return true
    elseif a["goals_difference"] < b["goals_difference"] then
        return false
    elseif a["wins"] > b["wins"] then
        return true
    elseif a["wins"] < b["wins"] then
        return false
    elseif a["team"] < b["team"] then
        return true
    elseif a["team"] > b["team"] then
        return false
    end
end

matches_path = arg[1]
local matches_file = io.open(matches_path, "r")
local matches_data = matches_file:read("*a")

local matches = json.decode(matches_data)
local league = {}

for _, match in ipairs(matches) do
    home_team = match["homeTeam"]
    away_team = match["awayTeam"]
    home_goals = match["homeGoals"]
    away_goals = match["awayGoals"]

    if league[home_team] == nil then
        league[home_team] = new_league_row(home_team)
    end
    if league[away_team] == nil then
        league[away_team] = new_league_row(away_team)
    end

    league[home_team]["goals_scored"] = league[home_team]["goals_scored"] + home_goals
    league[home_team]["goals_conceded"] = league[home_team]["goals_conceded"] + away_goals
    league[away_team]["goals_scored"] = league[away_team]["goals_scored"] + away_goals
    league[away_team]["goals_conceded"] = league[away_team]["goals_conceded"] + home_goals 

    if home_goals > away_goals then
        league[home_team]["wins"] = league[home_team]["wins"] + 1
        league[away_team]["defeats"] = league[away_team]["defeats"] + 1
    elseif home_goals < away_goals then
        league[home_team]["defeats"] = league[home_team]["defeats"] + 1
        league[away_team]["wins"] = league[away_team]["wins"] + 1
    else
        league[home_team]["ties"] = league[home_team]["ties"] + 1
        league[away_team]["ties"] = league[away_team]["ties"] + 1
    end
end

for team, row in pairs(league) do
    row["goals_difference"] = row["goals_scored"] - row["goals_conceded"]
    row["points"] = row["wins"] * 3 + row["ties"]
end

ordered = {}
for _, row in pairs(league) do
    table.insert(ordered, row)
end
table.sort(ordered, sort)

title = string.format("%25s %2s %2s %2s %2s %2s %2s %3s %2s",
                      "Name", "#", "w", "d", "l", "+", "-", "=", "P")
print(title)
print(string.rep("-", string.len(title)))
for i, row in pairs(ordered) do
    print(string.format("%25s %2d %2d %2d %2d %2d %2d %3d %2d",
                        row["team"], i+1,
                        row["wins"], row["ties"], row["defeats"],
                        row["goals_scored"], row["goals_conceded"], row["goals_difference"],
                        row["points"]))
end
