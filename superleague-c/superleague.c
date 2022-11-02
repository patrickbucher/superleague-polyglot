#include <stdio.h>
#include <stdlib.h>

#include "parsing.h"

int main(int argc, char *argv[])
{
    char *text = NULL;
    match_result *result = NULL;
    match_node *mn = NULL;

    if (argc < 2) {
        fprintf(stderr, "usage: %s [json-file]\n", argv[1]);
        exit(1);
    }

    text = read_file_or_die(argv[1]);

    for (mn = parse_results_or_die(text); mn != NULL; mn = mn ->next) {
        result = mn->value;
        printf("%s %d:%d %s\n",
               result->home_team, result->home_goals,
               result->away_goals, result->away_team);
    }

    return 0;
}

