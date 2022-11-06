import { readJsonSync } from 'https://deno.land/x/jsonfile/mod.ts';

if (Deno.args.length < 1) {
    console.log("usage: deno run superleague.js [json-file]");
    Deno.exit();
}
const jsonPath = Deno.args[0];
const matches = readJsonSync(jsonPath);
console.log(matches);

for (const m of matches) {
    console.log(`${m.homeTeam} ${m.homeGoals} : ${m.awayGoals} ${m.awayTeam}`);
}
