import { readJsonSync } from 'https://deno.land/x/jsonfile/mod.ts';

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
    const rowsUnranked = results.reduce((acc, rs) => {
        // FIXME: how to check this?
        if (acc.hasKey(rs.name)) {
            // TODO: accumulate
        } else {
            acc[name] = rs;
        }
    }, new Map());
    console.log(rowsUnranked);
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
