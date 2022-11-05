#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parsing.h"

typedef struct {
    char *name;
    int rank;
    int wins;
    int defeats;
    int ties;
    int goals_scored;
    int goals_conceded;
    int goals_diff;
    int points;
} table_row;

table_row *from_match(match_result *result, bool home);
table_row *fetch_row(table_row **table, char *name, int n);
void combine(table_row *existing, table_row *new);
table_row **accumulate(table_row **table, table_row *tr, int *n);
int before(const void *x, const void *y);

int main(int argc, char *argv[])
{
    char *text = NULL;
    match_node *head = NULL, *mn = NULL;
    table_row **table = NULL, *tr_new = NULL, *tr = NULL;
    int table_size = 0, i = 0;

    if (argc < 2) {
        fprintf(stderr, "usage: %s [json-file]\n", argv[1]);
        exit(1);
    }

    text = read_file_or_die(argv[1]);

    // import
    head = parse_results_or_die(text);

    // processing
    for (mn = head; mn != NULL; mn = mn->next) {
        // home team
        tr_new = from_match(mn->value, true);
        table = accumulate(table, tr_new, &table_size);

        // away team
        tr_new = from_match(mn->value, false);
        table = accumulate(table, tr_new, &table_size);
    }

    // sorting & ranking
    printf("sorting table of length %d\n", table_size);
    qsort(table, table_size, sizeof(table_row*), before);
    for (i = 0; i < table_size; i++) {
        table[i]->rank = i + 1;
    }

    // output
    printf("%30s %3s %3s %3s %4s %4s %4s %4s %4s\n",
           "Team", "#", "w", "t", "l", "+", "-", "=", "P");
    puts("-------------------------------------------------------------------");
    for (i = 0; i < table_size; i++) {
        tr = table[i];
        printf("%30s %3d %3d %3d %4d %4d %4d %4d %4d\n", tr->name, tr->rank,
               tr->wins, tr->ties, tr->defeats,
               tr->goals_scored, tr->goals_conceded, tr->goals_diff,
               tr->points);
    }

    // cleanup
    free(text);
    for (mn = head; mn != NULL; mn = mn->next) {
        free(mn->value->home_team);
        free(mn->value->away_team);
        free(mn->value);
    }
    for (i = 0; i < table_size; i++) {
        free(table[i]->name);
        free(table[i]);
    }
    free(table);
    while (head != NULL) {
        mn = head;
        head = mn->next;
        free(mn);
    }

    return 0;
}

table_row *from_match(match_result *result, bool home)
{
    table_row *tr = NULL;
    char *name = NULL;
    int n = 0;
    bool win = false, defeat = false;

    tr = malloc(sizeof(table_row));
    if (tr == NULL) {
        exit(1);
    }

    name = home ? result->home_team : result->away_team;
    n = strlen(name);
    tr->name = malloc(sizeof(char) * (n + 1));
    if (tr->name == NULL) {
        exit(1);
    }
    strncpy(tr->name, name, n);
    tr->name[n] = '\0';
    tr->rank = 0;

    if (home) {
        tr->goals_scored = result->home_goals;
        tr->goals_conceded = result->away_goals;
        win = result->home_goals > result->away_goals;
        defeat = result->home_goals < result->away_goals;
    } else {
        tr->goals_scored = result->away_goals;
        tr->goals_conceded = result->home_goals;
        win = result->home_goals < result->away_goals;
        defeat = result->home_goals > result->away_goals;
    }
    if (win) {
        tr->wins = 1;
        tr->defeats = 0;
        tr->ties = 0;
    } else if (defeat) {
        tr->wins = 0;
        tr->defeats = 1;
        tr->ties = 0;
    } else { // tie
        tr->wins = 0;
        tr->defeats = 0;
        tr->ties = 1;
    }
    tr->points = 3 * tr->wins + tr->ties;
    tr->goals_diff = tr->goals_scored - tr->goals_conceded;

    return tr;
}

table_row *fetch_row(table_row **table, char *name, int n)
{
    table_row *r = NULL;
    int i = 0, l = 0;

    l = strlen(name);
    for (i = 0; i < n; i++) {
        r = table[i];
        if (strncmp(name, r->name, l) == 0) {
            return r;
        }
    }

    return NULL;
}

void combine(table_row *existing, table_row *new)
{
    existing->goals_scored += new->goals_scored;
    existing->goals_conceded += new->goals_conceded;
    existing->goals_diff += new->goals_diff;
    existing->wins += new->wins;
    existing->defeats += new->defeats;
    existing->ties += new->ties;
    existing->points += new->points;
}

table_row **accumulate(table_row **table, table_row *tr_new, int *n)
{
    table_row *tr = NULL;

    if (table == NULL) {
        table = malloc(sizeof(table_row*));
        if (table == NULL) {
            exit(1);
        }
        table[0] = tr_new;
        *n = 1;
    } else {
        tr = fetch_row(table, tr_new->name, *n);
        if (tr != NULL) {
            combine(tr, tr_new);
            free(tr_new->name);
            free(tr_new);
        } else {
            (*n)++;
            table = realloc(table, sizeof(table_row*) * (*n));
            if (table == NULL) {
                exit(1);
            }
            table[(*n)-1] = tr_new;
        }
    }

    return table;
}

int before(const void *x, const void *y)
{
    const table_row *a = *(table_row**)x;
    const table_row *b = *(table_row**)y;

    // points (descending)
    if (a->points > b->points) {
        return -1;
    } else if (a->points < b->points) {
        return 1;
    }

    // wins (descending)
    if (a->wins > b->wins) {
        return -1;
    } else if (a->wins < b->wins) {
        return 1;
    }

    // goals diff (descending)
    if (a->goals_diff > b->goals_diff) {
        return -1;
    } else if (a->goals_diff < b->goals_diff) {
        return 1;
    }

    // name (ascending)
    return strcmp(a->name, b->name);
}