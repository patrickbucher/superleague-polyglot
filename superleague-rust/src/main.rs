use std::env;
use std::fs;
use std::process::ExitCode;

use superleague_rust::TableRow;

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();
    if (args.len()) != 2 {
        eprintln!("usage: {} [json-file]", args[0]);
        return ExitCode::from(1);
    }

    let json_file = &args[1];
    let data = fs::read_to_string(json_file).expect("Should have read file");
    let table = TableRow::from(data);

    println!(
        "{:>26} {:>3} {:>3} {:>3} {:>3} {:>3} {:>3} {:>4} {:>3}",
        "Team", "#", "w", "l", "d", "+", "-", "=", "P"
    );
    println!("-----------------------------------------------------------");
    for row in table {
        println!(
            "{:>26} {:>3} {:>3} {:>3} {:>3} {:>3} {:>3} {:>4} {:>3}",
            row.team,
            row.rank,
            row.wins,
            row.defeats,
            row.ties,
            row.goals_shot,
            row.goals_conceded,
            row.goals_diff,
            row.points
        );
    }

    ExitCode::SUCCESS
}
