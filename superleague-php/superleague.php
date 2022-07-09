<?php

$rows = array();
$json_data = file_get_contents($argv[1]);
$season = json_decode($json_data, true);

function newEntry($teamName) {
    return array(
        "team" => $teamName,
        "rank" => 0,
        "wins" => 0,
        "ties" => 0,
        "defeats" => 0,
        "goalsScored" => 0,
        "goalsConceded" => 0,
        "goalsDifference" => 0,
        "points" => 0,
    );
}

foreach ($season as $match) {
    $homeTeam = $match["homeTeam"];
    $awayTeam = $match["awayTeam"];
    $homeGoals = $match["homeGoals"];
    $awayGoals = $match["awayGoals"];

    if (!array_key_exists($homeTeam, $rows)) {
        $rows[$homeTeam] = newEntry($homeTeam);
    }
    if (!array_key_exists($awayTeam, $rows)) {
        $rows[$awayTeam] = newEntry($awayTeam);
    }

    $rows[$homeTeam]["goalsScored"] += $homeGoals;
    $rows[$homeTeam]["goalsConceded"] += $awayGoals;
    $rows[$awayTeam]["goalsScored"] += $awayGoals;
    $rows[$awayTeam]["goalsConceded"] += $homeGoals;

    if ($homeGoals > $awayGoals) {
        $rows[$homeTeam]["wins"]++;
        $rows[$awayTeam]["defeats"]++;
    } elseif ($homeGoals < $awayGoals) {
        $rows[$awayTeam]["wins"]++;
        $rows[$homeTeam]["defeats"]++;
    } else {
        $rows[$homeTeam]["ties"]++;
        $rows[$homeTeam]["points"]++;
        $rows[$awayTeam]["ties"]++;
    }
}

$rows = array_map(function ($row) {
	$row["goalsDifference"] = $row["goalsScored"] - $row["goalsConceded"];
	$row["points"] = $row["wins"] * 3 + $row["ties"];
	return $row;
}, $rows);

usort($rows, function ($a, $b) {
    if ($a["points"] > $b["points"]) {
        return -1;
    } elseif ($a["points"] < $b["points"]) {
        return 1;
    } elseif ($a["goalsDifference"] > $b["goalsDifference"]) {
        return -1;
    } elseif ($a["goalsDifference"] < $b["goalsDifference"]) {
        return 1;
    } elseif ($a["wins"] < $b["wins"]) {
        return -1;
    } elseif ($a["wins"] < $b["wins"]) {
        return 1;
    } elseif (strcasecmp($a["team"], $b["team"]) < 0) {
        return -1;
    } elseif (strcasecmp($a["team"], $b["team"]) > 0) {
        return 1;
    } else {
        return 0;
    }
});

print("                     Name  #  w  d  l  +  -   =  P\n");
print("--------------------------------------------------\n");
foreach ($rows as $k => $l) {
    printf("%25s %2d %2d %2d %2d %2d %2d %3d %2d\n",
        $l["team"], $k+1, $l["wins"], $l["ties"], $l["defeats"],
        $l["goalsScored"], $l["goalsConceded"], $l["goalsDifference"], $l["points"]);
}

?>
