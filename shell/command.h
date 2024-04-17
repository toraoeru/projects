#ifndef COMMAND_H
#define COMMAND_H

typedef struct Command {
    enum {
        KIND_SIMPLE,
        KIND_REDIRECT,
        KIND_PIPELINE,
        KIND_SEQ1,
        KIND_SEQ2
    } kind;

    struct { // for simple
        int argc;
        char **argv;
    }; 
    struct { // for redirect io
        enum {
            RD_INPUT,
            RD_OUTPUT,
            RD_APPEND
        } rd_mode;
        char *rd_path;
        struct Command *rd_command;
    }; 
    struct { // for pipeline
        int pipeline_size;
        struct Command *pipeline_commands;
    }; 
    struct { // for seq1 and seq 2
        int seq_size;
        struct Command *seq_commands;
        enum {
            OP_SEQ,
            OP_BACKGROUND,
            OP_DISJUNCT,
            OP_CONJUNCT
        } op;
        int *seq_operations;
    }; 
} Command;

int init_empty_command(Command *);
int init_sequence_command(Command *, int);
int append_command_to_sequence(Command *, Command *);
int append_operation_to_sequence(Command *, int);
int init_pipeline_command(Command *);
int append_to_pipeline(Command *, Command * );
int init_redirect_command(Command *);
int set_rd_command(Command *, Command *);
int init_simple_command(Command *);
int append_word_simple_command(Command *, char *);
void free_command(Command *);

#endif