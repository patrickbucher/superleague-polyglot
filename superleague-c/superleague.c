#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#include <jansson.h>

const int BUF_STEP = 1024;

typedef struct {
    char *home_team;
    char *away_team;
    int home_goals;
    int away_goals;
} result;

int main(int argc, char *argv[])
{
    FILE* f = NULL;
    char *text = NULL;
    char c = 0;
    size_t buflen = BUF_STEP;
    int bufpos = 0;

    json_t *root = NULL;
    json_error_t error;

    if (argc < 2) {
        fprintf(stderr, "usage: %s [json-file]\n", argv[1]);
        exit(1);
    }

    f = fopen(argv[1], "r");
    if (f == NULL) {
        fprintf(stderr, "cannot open file %s\n", argv[1]);
        exit(1);
    }

    text = malloc(sizeof(int) * buflen);
    if (text == NULL) {
        fprintf(stderr, "cannot allocate buffer of length %d\n", buflen);
        exit(1);
    }
    while ((c = fgetc(f)) != EOF) {
        // -1 for size/index offset, -1 for EOF
        if (bufpos == buflen - 2) {
            text = realloc(text, sizeof(int) * (buflen + BUF_STEP));
            if (text == NULL) {
                fprintf(stderr, "unable to grow buffer by %d to %d\n", BUF_STEP, buflen);
                exit(1);
            }
            buflen += BUF_STEP;
        }
        text[bufpos++] = c;
    }
    text[bufpos] = 0;
    fclose(f);

    root = json_loads(text, 0, &error);
    free(text);
    if (root == NULL) {
        fprintf(stderr, "parsing text: %s\n", error.text);
        exit(1);
    }
    if (!json_is_array(root)) {
        fprintf(stderr, "not an array\n");
        exit(1);
    }

    // TODO: find general solution
    json_t *entry = json_array_get(root, 0);
    if (!json_is_object(entry)) {
        fprintf(stderr, "not an object\n");
        exit(1);
    }
    result *match_result = malloc(sizeof(result));
    parse_or_die(entry, match_result);
    printf("%s %d:%d %s\n",
        match_result->home_team, match_result->home_goals,
        match_result->away_goals, match_result->away_team);

    return 0;
}

void parse_or_die(json_t *data, result *target) {
    json_t *home_team, *away_team, *home_goals, *away_goals;

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

    // TODO: proper memcopy for strings, free stuff...
    target->home_team = json_string_value(home_team);
    target->away_team = json_string_value(away_team);
    target->home_goals = json_integer_value(home_goals);
    target->away_goals = json_integer_value(away_goals);
}