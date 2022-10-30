#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <jansson.h>

const size_t BUF_STEP = 1024;

typedef struct {
    char *home_team;
    char *away_team;
    int home_goals;
    int away_goals;
} match_result;

typedef struct {
    match_result *value;
    match_result *next;
} match_node;

char *read_file_or_die(char *path);
match_result **parse_array_or_die(char *raw_json);
match_result *parse_result_or_die(json_t *data);

int main(int argc, char *argv[])
{
    char *text = NULL;
    match_result **results = NULL;
    match_result *result = NULL;

    if (argc < 2) {
        fprintf(stderr, "usage: %s [json-file]\n", argv[1]);
        exit(1);
    }

    text = read_file_or_die(argv[1]);
    results = parse_array_or_die(text);

    for (int i = 0; i < sizeof(*results) / sizeof(match_result*); i++) {
        result = results[i];
        printf("%s %d:%d %s\n",
               result->home_team, result->home_goals,
               result->away_goals, result->away_team);
    }

    return 0;
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
    ht = (char*)json_string_value(home_team);
    at = (char*)json_string_value(away_team);
    hg = (int)json_integer_value(home_goals);
    ag = (int)json_integer_value(away_goals);

    n = strlen(ht) + 1;
    result->home_team = malloc(sizeof(char) * n);
    memcpy(result->home_team, ht, n);

    n = strlen(at) + 1;
    result->away_team = malloc(sizeof(char) * n);
    memcpy(result->away_team, at, n);

    result->home_goals = hg;
    result->away_goals = ag;

    return result;
}

match_result **parse_array_or_die(char *raw_json)
{
    json_t *root = NULL;
    json_error_t error;
    int i = 0, n = 0;
    json_t *entry;
    match_result **results = NULL;

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
    results = malloc(sizeof(match_result*) * n);
    for (i = 0; i < n; i++) {
        entry = json_array_get(root, i);
        if (!json_is_object(entry)) {
            fprintf(stderr, "unable to parse entry at index %d\n", i);
            exit(1);
        }
        results[i] = parse_result_or_die(entry);
        json_decref(entry);
    }

    return results;
}

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
        fprintf(stderr, "cannot allocate buffer of length %zu\n", buflen);
        exit(1);
    }
    while ((c = fgetc(f)) != EOF) {
        // -1 for size/index offset, -1 for EOF
        if (bufpos == buflen - 2) {
            text = realloc(text, sizeof(int) * (buflen + BUF_STEP));
            if (text == NULL) {
                fprintf(stderr, "unable to grow buffer by %zu to %zu\n", BUF_STEP, buflen);
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