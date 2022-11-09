import { readJsonSync } from 'https://deno.land/x/jsonfile/mod.ts';
import { printf } from "https://deno.land/std@0.160.0/fmt/printf.ts";

main();

function main(args) {
    if (Deno.args.length < 1) {
        console.log("usage: deno run superleague.js [json-file]");
        Deno.exit();
    }
    const matches = readJsonSync(Deno.args[0]);
    const nestedResults = matches.map(toTableRows);
    const results = nestedResults.reduce((acc, rs) => {
        acc.push(rs[0]);
        acc.push(rs[1]);
        return acc;
    }, []);
    const rowsByTeam = results.reduce((acc, rs) => {
        if (acc.has(rs.name)) {
            acc.set(rs.name, accumulate(acc.get(rs.name), rs));
        } else {
            acc.set(rs.name, rs);
        }
        return acc;
    }, new Map());
    const table = new Array();
    for (const row of rowsByTeam.values()) {
        table.push(row);
    }
    table.sort(before);
    for (let i = 0; i < table.length; i++) {
        table[i].rank = i + 1;
    }
    output(table);
}

function output(table) {
    printf("%30s %3s %3s %3s %3s %4s %4s %4s %4s\n",
        "Team", "#", "w", "t", "l", "+", "-", "=", "P");
    printf("------------------------------------------------------------------\n");
    for (const row of table) {
        printf("%30s %3d %3d %3d %3d %4d %4d %4d %4d\n",
            row.name, row.rank, row.wins, row.ties, row.defeats,
            row.goalsScored, row.goalsConceded, row.goalsDiff, row.points);
    }
}

function before(a, b) {
    if (a.points > b.points) {
        return -1;
    } else if (a.points < b.points) {
        return 1;
    }

    if (a.wins > b.wins) {
        return -1;
    } else if (a.wins < b.wins) {
        return 1;
    }

    if (a.goalsScored > b.goalsScored) {
        return -1;
    } else if (a.goalsScored < b.goalsScored) {
        return 1;
    }

    return a.name < b.name ? -1 : 1;
}

function accumulate(row, total) {
    return {
        name: total.name,
        rank: total.rank,
        goalsScored: row.goalsScored + total.goalsScored,
        goalsConceded: row.goalsConceded + total.goalsConceded,
        goalsDiff: row.goalsDiff + total.goalsDiff,
        wins: row.wins + total.wins,
        defeats: row.defeats + total.defeats,
        ties: row.ties + total.ties,
        points: row.points + total.points
    };
}

function toTableRows(match) {
    const newRow = (name, goalsScored, goalsConceded) => {
        const row = {
            name: name,
            rank: 0,
            goalsScored: goalsScored,
            goalsConceded: goalsConceded,
            goalsDiff: goalsScored - goalsConceded,
            wins: (goalsScored > goalsConceded) ? 1 : 0,
            defeats: (goalsScored < goalsConceded) ? 1 : 0,
            ties: (goalsScored == goalsConceded) ? 1 : 0,
        };
        row.points = row.wins * 3 + row.ties;
        return row;
    };
    const ht = match.homeTeam;
    const at = match.awayTeam;
    const hg = match.homeGoals;
    const ag = match.awayGoals;
    return [newRow(ht, hg, ag), newRow(at, ag, hg)];
}
