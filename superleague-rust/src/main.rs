use serde;
use serde_json;
use std::env;
use std::fs;
use std::process::ExitCode;

#[derive(Debug, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
struct Result {
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

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();
    if (args.len()) != 2 {
        eprintln!("usage: {} [json-file]", args[0]);
        return ExitCode::from(1);
    }

    let json_file = &args[1];
    let data = fs::read_to_string(json_file).expect("Should have read file");
    let results: Vec<Result> = serde_json::from_str(&data).expect("Should have parsed JSON");
    let team_results: Vec<(TeamResult, TeamResult)> = results.iter().map(|r| {
        (
            TeamResult {
                team: r.home_team.clone(),
                goals_shot: r.home_goals,
                goals_conceded: r.away_goals,
            },
            TeamResult {
                team: r.away_team.clone(),
                goals_shot: r.away_goals,
                goals_conceded: r.home_goals,
            },
        )
    }).collect();
    let flat_results: Vec<&TeamResult> = team_results.iter().flat_map(|rs| [&rs.0, &rs.1]).collect();

    dbg!(flat_results);

    ExitCode::SUCCESS
}
