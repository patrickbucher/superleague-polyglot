#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <jansson.h>

#include "parsing.h"

char *read_file_or_die(char *path)
{
    FILE* f = NULL;
    char *text = NULL;
    char c = 0;
    size_t buflen = BUF_STEP;
    int bufpos = 0;

    f = fopen(path, "r");
    if (f == NULL) {
        fprintf(stderr, "cannot open file %s\n", path);
        exit(1);
    }

    text = malloc(sizeof(int) * buflen);
    if (text == NULL) {
        exit(1);
    }
    while ((c = fgetc(f)) != EOF) {
        // -1 for size/index offset, -1 for EOF
        if (bufpos == buflen - 2) {
            text = realloc(text, sizeof(int) * (buflen + BUF_STEP));
            if (text == NULL) {
                exit(1);
            }
            buflen += BUF_STEP;
        }
        text[bufpos++] = c;
    }
    text[bufpos] = 0;
    fclose(f);

    return text;
}

match_node *parse_results_or_die(char *raw_json)
{
    json_t *root = NULL;
    json_error_t error;
    int i = 0, n = 0;
    json_t *entry;
    match_node *head = NULL, *new = NULL;

    root = json_loads(raw_json, 0, &error);
    if (root == NULL) {
        fprintf(stderr, "parsing text: %s\n", error.text);
        exit(1);
    }

    if (!json_is_array(root)) {
        fprintf(stderr, "not an array\n");
        exit(1);
    }

    n = json_array_size(root);
    for (i = 0; i < n; i++) {
        entry = json_array_get(root, i);
        if (!json_is_object(entry)) {
            fprintf(stderr, "unable to parse entry at index %d\n", i);
            exit(1);
        }

        new = malloc(sizeof(match_node));
        if (new == NULL) {
            exit(1);
        }
        new->value = parse_result_or_die(entry);
        new->next = NULL;
        if (head != NULL) {
            new->next = head;
        }
        head = new;
    }
    json_decref(root);

    return head;
}

match_result *parse_result_or_die(json_t *data)
{
    match_result *result;
    json_t *home_team, *away_team, *home_goals, *away_goals;
    int hg = 0, ag = 0;
    char *ht = NULL, *at = NULL;
    size_t n = 0;

    if (!json_is_object(data)) {
        fprintf(stderr, "data is not an object\n");
        exit(1);
    }

    home_team = json_object_get(data, "homeTeam");
    away_team = json_object_get(data, "awayTeam");
    home_goals = json_object_get(data, "homeGoals");
    away_goals = json_object_get(data, "awayGoals");
    if (!json_is_string(home_team) || !json_is_string(away_team) ||
            !json_is_integer(home_goals) || !json_is_integer(away_goals)) {
        fprintf(stderr, "error parsing home/away data\n");
        exit(1);
    }

    result = malloc(sizeof(match_result));
    if (result == NULL) {
        exit(1);
    }
    ht = (char*)json_string_value(home_team);
    at = (char*)json_string_value(away_team);
    hg = (int)json_integer_value(home_goals);
    ag = (int)json_integer_value(away_goals);

    n = strlen(ht) + 1;
    result->home_team = malloc(sizeof(char) * n);
    if (result->home_team == NULL) {
        exit(1);
    }
    memcpy(result->home_team, ht, n);

    n = strlen(at) + 1;
    result->away_team = malloc(sizeof(char) * n);
    if (result->away_team == NULL) {
        exit(1);
    }
    memcpy(result->away_team, at, n);

    result->home_goals = hg;
    result->away_goals = ag;

    return result;
}

