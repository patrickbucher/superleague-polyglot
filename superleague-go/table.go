package superleague

import (
	"bytes"
	"fmt"
	"sort"
	"strings"
)

type Match struct {
	HomeTeam  string `json:"homeTeam"`
	AwayTeam  string `json:"awayTeam"`
	HomeGoals int    `json:"homeGoals"`
	AwayGoals int    `json:"awayGoals"`
}

type TableRow struct {
	Team            string
	Rank            int
	Wins            int
	Ties            int
	Defeats         int
	GoalsScored     int
	GoalsConceded   int
	GoalsDifference int
	Points          int
}

type Table []TableRow

func (t Table) Len() int      { return len(t) }
func (t Table) Swap(i, j int) { t[i], t[j] = t[j], t[i] }
func (t Table) Less(i, j int) bool {
	if t[i].Points > t[j].Points {
		return true
	} else if t[i].Points < t[j].Points {
		return false
	} else if t[i].GoalsDifference > t[j].GoalsDifference {
		return true
	} else if t[i].GoalsDifference < t[j].GoalsDifference {
		return false
	} else if t[i].Wins > t[j].Wins {
		return true
	} else if t[i].Wins < t[j].Wins {
		return false
	}
	return strings.Compare(t[i].Team, t[j].Team) == -1
}

func (t Table) String() string {
	const titleFormat = "%30s %2s %2s %2s %2s %3s %3s %3s %3s"
	const rowFormat = "%30s %2d %2d %2d %2d %3d %3d %3d %3d"
	buf := bytes.NewBufferString("")
	titleRow := fmt.Sprintf(titleFormat, "Team", "#", "W", "D", "L", "+", "-", "=", "P")
	fmt.Fprintln(buf, titleRow)
	fmt.Fprintln(buf, strings.Repeat("-", len(titleRow)))
	for _, r := range t {
		row := fmt.Sprintf(rowFormat, r.Team, r.Rank, r.Wins, r.Ties, r.Defeats,
			r.GoalsScored, r.GoalsConceded, r.GoalsDifference, r.Points)
		fmt.Fprintln(buf, row)
	}
	return buf.String()
}

func CreateTable(matches []Match) (Table, error) {
	rowsByTeam := make(map[string]*TableRow)
	for _, match := range matches {
		if _, ok := rowsByTeam[match.HomeTeam]; !ok {
			rowsByTeam[match.HomeTeam] = &TableRow{Team: match.HomeTeam}
		}
		if _, ok := rowsByTeam[match.AwayTeam]; !ok {
			rowsByTeam[match.AwayTeam] = &TableRow{Team: match.AwayTeam}
		}
		homeRow := rowsByTeam[match.HomeTeam]
		awayRow := rowsByTeam[match.AwayTeam]
		homeRow.GoalsScored += match.HomeGoals
		awayRow.GoalsScored += match.AwayGoals
		homeRow.GoalsConceded += match.AwayGoals
		awayRow.GoalsConceded += match.HomeGoals
		if match.HomeGoals > match.AwayGoals {
			homeRow.Wins++
			awayRow.Defeats++
		} else if match.HomeGoals < match.AwayGoals {
			awayRow.Wins++
			homeRow.Defeats++
		} else {
			homeRow.Ties++
			awayRow.Ties++
		}
	}
	var table Table
	for _, row := range rowsByTeam {
		table = append(table, *row)
	}
	sort.Sort(table)
	for i := range table {
		table[i].Rank = i + 1
		table[i].Points = table[i].Wins*3 + table[i].Ties
		table[i].GoalsDifference = table[i].GoalsScored - table[i].GoalsConceded
	}
	return table, nil
}
