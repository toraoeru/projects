#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <wait.h>
#include "runner.h"

int
simple_cmd(Command *command)
{
    execvp(command->argv[0], command->argv);
    exit(1);
    return 1;
}

int
run_command(Command *command)
{
    switch (command->kind) {
    case KIND_SIMPLE:
        return simple_cmd(command);
    case KIND_REDIRECT:
        return redirect_cmd(command);
    case KIND_PIPELINE:
        return pipeline_cmd(command);
    case KIND_SEQ1: 
        return seq1_cmd(command);
    case KIND_SEQ2: 
        return seq2_cmd(command);
    default:
        return 0;
    }
    return 0;
}

int
rd_input_cmd(Command *command)
{
    int fd = open(command->rd_path, O_RDONLY);
    if (fd == -1) {
        return 1;
    }
    dup2(fd, STDIN_FILENO);
    close(fd);
    return run_command(command->rd_command);
}

int
rd_output_cmd(Command *command)
{
    int fd = open(command->rd_path, O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (fd == -1) {
        return 1;
    }
    dup2(fd, STDOUT_FILENO);
    close(fd);
    return run_command(command->rd_command);
}

int
rd_append_cmd(Command *command)
{
    int fd = open(command->rd_path, O_WRONLY | O_CREAT | O_APPEND, 0666);
    if (fd == -1) {
        return 1;
    }
    dup2(fd, STDOUT_FILENO);
    close(fd);
    return run_command(command->rd_command);
}

int
redirect_cmd(Command *command)
{
    switch (command->rd_mode)
    {
    case RD_INPUT:
        return rd_input_cmd(command);
    case RD_OUTPUT:
        return rd_output_cmd(command);
    case RD_APPEND:
        return rd_append_cmd(command);
    default:
        return 0;
    }
}

int
pipeline_cmd(Command *command)
{
    int pid = 0, fd[2], status = 0;
    int orig_input = dup(STDIN_FILENO);
    int orig_output = dup(STDOUT_FILENO);
    for (int i = 0; i < command->pipeline_size; ++i) {
        if (i != 0) {
            dup2(fd[0], STDIN_FILENO);
            close(fd[0]);
        }
        if (pipe(fd) == -1) {
            return 1;
        }
        if (i == command->pipeline_size - 1) {
            dup2(orig_output, STDOUT_FILENO);
        } else {
            dup2(fd[1], STDOUT_FILENO);
        }
        close(fd[1]);
        if ((pid = fork()) == 0) {
            close(fd[0]);
            close(orig_input);
            close(orig_output);
            exit(run_command(command->pipeline_commands + i));
        }
    }
    close(fd[0]); ///
    close(orig_output);
    dup2(orig_input, STDIN_FILENO);
    close(orig_input);
    waitpid(pid, &status, 0);
    while (wait(NULL) != -1);
    return status;
}

int 
seq1_cmd(Command *command) 
{
    int status = 0;
    for (int i = 0; i < command->seq_size; ++i) {
        switch (command->seq_operations[i]) {
        case OP_SEQ:
            status = run_command(command->seq_commands + i);
            break;
        case OP_BACKGROUND:
            if (fork() == 0) {
                if (fork() == 0) {
                    exit(run_command(command->seq_commands + i));
                }
                exit(0);
            }
            wait(NULL);
            break;
        default:
            return 0;
        }
    }
    return status;
}

int 
seq2_cmd(Command *command) 
{
    int status = run_command(command->seq_commands);
    for (int i = 1; i < command->seq_size; ++i) {
        if (((command->seq_operations[i - 1] == OP_CONJUNCT) && !status)) {
            status = run_command(command->seq_commands + i);
        } else if ((command->seq_operations[i - 1] == OP_DISJUNCT) && status) {
            status = run_command(command->seq_commands + i);
        }
    }
    return status;
}