#include <stdio.h>
#include <stdlib.h>

#include "parsing.h"

int main(int argc, char *argv[])
{
    char *text = NULL;
    match_result *result = NULL;
    match_node *head = NULL, *mn = NULL;

    if (argc < 2) {
        fprintf(stderr, "usage: %s [json-file]\n", argv[1]);
        exit(1);
    }

    text = read_file_or_die(argv[1]);

    head = parse_results_or_die(text);
    free(text);
    for (mn = head; mn != NULL; mn = mn ->next) {
        result = mn->value;
        printf("%s %d:%d %s\n",
               result->home_team, result->home_goals,
               result->away_goals, result->away_team);
    }

    // cleanup
    for (mn = head; mn != NULL; mn = mn->next) {
        free(mn->value->home_team);
        free(mn->value->away_team);
        free(mn->value);
    }
    while (head != NULL) {
        mn = head;
        head = mn->next;
        free(mn);
    }

    return 0;
}

