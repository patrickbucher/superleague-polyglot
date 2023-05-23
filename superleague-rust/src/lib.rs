use serde;
use std::cmp::Ordering;
use std::collections::hash_map::Entry;
use std::collections::HashMap;

pub struct TableRow {
    pub team: String,
    pub rank: u8,
    pub wins: u8,
    pub defeats: u8,
    pub ties: u8,
    pub goals_shot: u8,
    pub goals_conceded: u8,
    pub goals_diff: i8,
    pub points: u8,
}

#[derive(serde::Deserialize)]
#[serde(rename_all = "camelCase")]
struct MatchResult {
    home_team: String,
    away_team: String,
    home_goals: u8,
    away_goals: u8,
}

struct TeamResult {
    team: String,
    goals_shot: u8,
    goals_conceded: u8,
}

impl TableRow {
    pub fn from(raw_json: String) -> Vec<TableRow> {
        let results: Vec<MatchResult> =
            serde_json::from_str(&raw_json).expect("Should have parsed JSON");
        let team_results: Vec<(TeamResult, TeamResult)> =
            results.iter().map(to_team_results).collect();
        let flat_results: Vec<&TeamResult> =
            team_results.iter().flat_map(|rs| [&rs.0, &rs.1]).collect();
        let single_result_table_rows: Vec<TableRow> =
            flat_results.iter().map(|r| to_table_row(&r)).collect();
        let rows_by_team: HashMap<String, Vec<TableRow>> = group_by_team(single_result_table_rows);
        let mut table: Vec<TableRow> = combine_rows(rows_by_team);
        table.sort_by(|a, b| {
            b.points
                .cmp(&a.points)
                .then(b.goals_diff.cmp(&a.goals_diff))
                .then(b.goals_shot.cmp(&a.goals_shot))
                .then(a.team.cmp(&b.team))
        });
        table
            .into_iter()
            .enumerate()
            .map(|(i, r)| TableRow {
                rank: i as u8 + 1,
                ..r
            })
            .collect()
    }
    fn new(team: String) -> TableRow {
        TableRow {
            team: team,
            rank: 0,
            wins: 0,
            defeats: 0,
            ties: 0,
            goals_shot: 0,
            goals_conceded: 0,
            goals_diff: 0,
            points: 0,
        }
    }
}

fn combine_rows(rows_by_team: HashMap<String, Vec<TableRow>>) -> Vec<TableRow> {
    rows_by_team
        .iter()
        .map(|(team, rows)| {
            rows.iter()
                .fold(TableRow::new(team.clone()), |acc, r| TableRow {
                    team: acc.team,
                    rank: 0,
                    wins: acc.wins + r.wins,
                    defeats: acc.defeats + r.defeats,
                    ties: acc.ties + r.ties,
                    goals_shot: acc.goals_shot + r.goals_shot,
                    goals_conceded: acc.goals_conceded + r.goals_conceded,
                    goals_diff: acc.goals_diff + r.goals_diff,
                    points: acc.points + r.points,
                })
        })
        .collect()
}

fn group_by_team(rows: Vec<TableRow>) -> HashMap<String, Vec<TableRow>> {
    rows.into_iter().fold(HashMap::new(), |mut acc, r| {
        match acc.entry(r.team.clone()) {
            Entry::Vacant(e) => {
                e.insert(vec![r]);
            }
            Entry::Occupied(mut e) => {
                e.get_mut().push(r);
            }
        };
        acc
    })
}

fn to_table_row(result: &TeamResult) -> TableRow {
    let row = TableRow {
        team: result.team.clone(),
        rank: 0,
        goals_shot: result.goals_shot,
        goals_conceded: result.goals_conceded,
        goals_diff: result.goals_shot as i8 - result.goals_conceded as i8,
        wins: 0,
        defeats: 0,
        ties: 0,
        points: 0,
    };
    match row.goals_shot.cmp(&row.goals_conceded) {
        Ordering::Greater => TableRow {
            points: 3,
            wins: 1,
            ..row
        },
        Ordering::Less => TableRow {
            points: 0,
            defeats: 1,
            ..row
        },
        Ordering::Equal => TableRow {
            points: 1,
            ties: 1,
            ..row
        },
    }
}

fn to_team_results(result: &MatchResult) -> (TeamResult, TeamResult) {
    (
        TeamResult {
            team: result.home_team.clone(),
            goals_shot: result.home_goals,
            goals_conceded: result.away_goals,
        },
        TeamResult {
            team: result.away_team.clone(),
            goals_shot: result.away_goals,
            goals_conceded: result.home_goals,
        },
    )
}

#[cfg(test)]
mod tests {
    #[test]
    fn todo() {
        assert_eq!(1 + 1, 2);
    }
}
