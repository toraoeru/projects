#ifndef RUNNER_H
#define RUNNER_H
#include "command.h"

int run_command(Command *);
int simple_cmd(Command *);
int redirect_cmd(Command *);
int rd_input_cmd(Command *);
int rd_output_cmd(Command *);
int rd_append_cmd(Command *);
int pipeline_cmd(Command *);
int seq1_cmd(Command *);
int seq2_cmd(Command *);

#endif