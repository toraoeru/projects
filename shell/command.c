#include "command.h"
#include <stdlib.h>

int
init_empty_command(Command *cmd)
{
    *cmd = (Command){0};
    return 0;
}

int
init_sequence_command(Command *cmd, int kind)
{
    init_empty_command(cmd);
    cmd->kind = kind;
    return 0;
}

int
append_command_to_sequence(Command *cmd1, Command *cmd2)
{
    Command *cur = realloc(cmd1->seq_commands, (cmd1->seq_size + 1) * sizeof *cmd1);
    if (!cur) {
        return 1;
    }
    cmd1->seq_commands = cur;
    ++(cmd1->seq_size);
    cmd1->seq_commands[cmd1->seq_size - 1] = *cmd2;
    return 0;
}

int
append_operation_to_sequence(Command *cmd, int op)
{
    int *cur_op = realloc(cmd->seq_operations, cmd->seq_size * sizeof op);
    if (!cur_op) {
        return 1;
    }
    cmd->seq_operations = cur_op;
    cmd->seq_operations[cmd->seq_size - 1] = op;
    return 0;
}

int
init_pipeline_command(Command *cmd)
{
    init_empty_command(cmd);
    cmd->kind = KIND_PIPELINE;
    return 0;
}

int
append_to_pipeline(Command *cmd1, Command *cmd2)
{
    Command *cur = realloc(cmd1->pipeline_commands, (cmd1->pipeline_size + 1) * sizeof *cmd1);
    if (!cur) {
        return 1;
    }
    cmd1->pipeline_commands = cur;
    ++(cmd1->pipeline_size);
    cmd1->pipeline_commands[cmd1->pipeline_size - 1] = *cmd2;
    return 0;
}

int
init_redirect_command(Command *cmd)
{
    init_empty_command(cmd);
    cmd->kind = KIND_REDIRECT;
    return 0;
}

int
set_rd_command(Command *cmd1, Command *cmd2)
{
    if (!(cmd1->rd_command = realloc(cmd1->rd_command, sizeof *cmd1))) {
        return 1;
    }
    *(cmd1->rd_command) = *cmd2;
    return 0;
}

int
init_simple_command(Command *cmd)
{
    init_empty_command(cmd);
    if (!(cmd->argv = malloc(sizeof *cmd->argv))) {
        return 1;
    }
    *cmd->argv = NULL;
    cmd->kind = KIND_SIMPLE;
    return 0;
}



int
append_word_simple_command(Command *cmd, char *arg)
{
    ++(cmd->argc);
    char **cur = realloc(cmd->argv, (cmd->argc + 1) * sizeof *cmd->argv);
    if (!cur) {
        return 1;
    }
    cmd->argv = cur;
    cmd->argv[cmd->argc - 1] = arg;
    cmd->argv[cmd->argc] = NULL;
    return 0;
}

void
free_command(Command *cmd)
{
    switch (cmd->kind) {
    case KIND_SIMPLE:
        for (int i = 0; i < cmd->argc; ++i) {
            free(cmd->argv[i]);
        }
        free(cmd->argv);
        break;
    case KIND_REDIRECT:
        free(cmd->rd_path);
        if (cmd->rd_command != NULL) {
            free_command(cmd->rd_command);
        }
        free(cmd->rd_command);
        break;
    case KIND_PIPELINE:
        for (int i = 0; i < cmd->pipeline_size; ++i) {
            free_command(cmd->pipeline_commands + i);
        }
        free(cmd->pipeline_commands);
        break;
    case KIND_SEQ1:
    case KIND_SEQ2:
        for (int i = 0; i < cmd->seq_size; ++i) {
            free_command(cmd->seq_commands + i);
        }
        free(cmd->seq_commands);
        free(cmd->seq_operations);
        break;
    default:
        break;
    }
}
