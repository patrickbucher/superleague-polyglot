use serde;
use serde_json;
use std::env;
use std::fs;
use std::process::ExitCode;

#[derive(Debug, serde::Deserialize)]
#[serde(rename_all = "camelCase")]
struct Match {
    home_team: String,
    away_team: String,
    home_goals: u8,
    away_goals: u8,
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();
    if (args.len()) != 2 {
        eprintln!("usage: {} [json-file]", args[0]);
        return ExitCode::from(1);
    }

    let json_file = &args[1];
    let data = fs::read_to_string(json_file).expect("Should have read file");
    let matches: Vec<Match> = serde_json::from_str(&data).expect("Should have parsed JSON");
    dbg!(matches);

    ExitCode::SUCCESS
}
