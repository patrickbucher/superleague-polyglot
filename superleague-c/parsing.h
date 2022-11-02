#include <jansson.h>

static const size_t BUF_STEP = 1024;

typedef struct {
    char *home_team;
    char *away_team;
    int home_goals;
    int away_goals;
} match_result;

typedef struct match_node {
    struct match_node *next;
    match_result *value;
} match_node;

char *read_file_or_die(char *path);
match_node *parse_results_or_die(char *raw_json);
match_result *parse_result_or_die(json_t *data);
