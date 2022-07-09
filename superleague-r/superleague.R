#!/usr/bin/env Rscript

library(jsonlite)
library(readr)

column_names <- c("name", "rank", "wins", "ties", "defeats",
                  "goalsScored", "goalsConceded", "goalsDifference",
                  "points")

create_empty_row <- function(teamName) {
    row <- data.frame(teamName, 0, 0, 0, 0, 0, 0, 0, 0)
    colnames(row) <- column_names
    return(row)
}

args <- commandArgs(trailingOnly=TRUE)
data <- read_file(args[1])
matches <- fromJSON(data)

table <- data.frame(matrix(ncol=9, nrow=0))
colnames(table) <- column_names

for (row in 1:nrow(matches)) {
    homeTeam <- matches[row, "homeTeam"]
    awayTeam <- matches[row, "awayTeam"]
    homeGoals <- matches[row, "homeGoals"]
    awayGoals <- matches[row, "awayGoals"]

    homeIndex <- which(table$name == homeTeam)
    awayIndex <- which(table$name == awayTeam)
    if (length(homeIndex) == 0) {
        table <- rbind(table, create_empty_row(homeTeam))
        homeIndex <- which(table$name == homeTeam)
    }
    if (length(awayIndex) == 0) {
        table <- rbind(table, create_empty_row(awayTeam))
        awayIndex <- which(table$name == awayTeam)
    }

    table[homeIndex, "goalsScored"] <- table[homeIndex, "goalsScored"] + homeGoals
    table[awayIndex, "goalsScored"] <- table[awayIndex, "goalsScored"] + awayGoals
    table[homeIndex, "goalsConceded"] <- table[homeIndex, "goalsConceded"] + awayGoals
    table[awayIndex, "goalsConceded"] <- table[awayIndex, "goalsConceded"] + homeGoals

    if (homeGoals > awayGoals) {
        table[homeIndex, "wins"] <- table[homeIndex, "wins"] + 1
        table[awayIndex, "defeats"] <- table[awayIndex, "defeats"] + 1
    } else if (homeGoals < awayGoals) {
        table[awayIndex, "wins"] <- table[awayIndex, "wins"] + 1
        table[homeIndex, "defeats"] <- table[homeIndex, "defeats"] + 1
    } else {
        table[homeIndex, "ties"] <- table[homeIndex, "ties"] + 1
        table[awayIndex, "ties"] <- table[awayIndex, "ties"] + 1
    }
}

for (row in 1:nrow(table)) {
    table[row, "goalsDifference"] <- table[row, "goalsScored"] - table[row, "goalsConceded"]
    table[row, "points"] <- table[row, "wins"] * 3 + table[row, "ties"]
}

table <- table[order(table$points, table$goalsDifference, table$wins, rev(table$name), decreasing=TRUE),]

for (row in 1:nrow(table)) {
    table[row, "rank"] <- row
}

cat("                     Name  #  w  d  l  +  -   =  P\n")
cat("--------------------------------------------------\n")
for (row in 1:nrow(table)) {
    r = table[row,]
    i = r$rank
    n = r$name
    w = r$wins
    d = r$ties
    l = r$defeats
    gs = r$goalsScored
    gc = r$goalsConceded
    gd = r$goalsDifference
    p = r$points
    format(n, width=25, justify="right")
    line = sprintf("%25s %2d %2d %2d %2d %2d %2d %3d %2d\n", n, i, w, d, l, gs, gc, gd, p)
    cat(line)
}
