use serde;
use serde_json;
use std::cmp::Ordering;
use std::collections::hash_map::Entry;
use std::collections::HashMap;
use std::env;
use std::fs;
use std::process::ExitCode;

#[derive(Debug, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
struct MatchResult {
    home_team: String,
    away_team: String,
    home_goals: u8,
    away_goals: u8,
}

#[derive(Debug)]
struct TeamResult {
    team: String,
    goals_shot: u8,
    goals_conceded: u8,
}

#[derive(Debug)]
struct TableRow {
    team: String,
    rank: u8,
    wins: u8,
    defeats: u8,
    ties: u8,
    goals_shot: u8,
    goals_conceded: u8,
    goals_diff: i8,
    points: u8,
}

impl TableRow {
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

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();
    if (args.len()) != 2 {
        eprintln!("usage: {} [json-file]", args[0]);
        return ExitCode::from(1);
    }

    let json_file = &args[1];
    let data = fs::read_to_string(json_file).expect("Should have read file");
    let results: Vec<MatchResult> = serde_json::from_str(&data).expect("Should have parsed JSON");
    let team_results: Vec<(TeamResult, TeamResult)> = results.iter().map(to_team_results).collect();
    let flat_results: Vec<&TeamResult> =
        team_results.iter().flat_map(|rs| [&rs.0, &rs.1]).collect();
    let single_result_table_rows: Vec<TableRow> =
        flat_results.iter().map(|r| to_table_row(&r)).collect();
    let rows_by_team: HashMap<String, Vec<TableRow>> = group_by_team(single_result_table_rows);
    let rows_combined: HashMap<String, TableRow> = combine_rows(rows_by_team);

    // TODO: sorting, ranking, output

    dbg!(rows_combined);

    ExitCode::SUCCESS
}

fn combine_rows(rows_by_team: HashMap<String, Vec<TableRow>>) -> HashMap<String, TableRow> {
    rows_by_team
        .iter()
        .map(|(team, rows)| {
            (
                team.clone(),
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
                    }),
            )
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
