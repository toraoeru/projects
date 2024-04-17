#include <stdio.h>

#include "command.h"
#include "errors.h"
#include "parser.h"
#include "runner.h"

int
main(void)
{
    int r;

    while (1) {

        if ((r = init_parser(stdin)) != 0) {
            fprintf(stderr, "%s\n", error_message(r));
            return 0;
        }

        Command c;
        if ((r = next_command(&c)) == EOF && feof(stdin)) {
            free_parser();
            break;
        } else if (r != 0) {
            fprintf(stderr, "%s\n", error_message(r));
            free_parser();
            continue;
        }

        run_command(&c);
        free_command(&c);
        free_parser();
    }

    return 0;
}
