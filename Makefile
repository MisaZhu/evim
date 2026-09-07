# Makefile — native macOS/OSX build of the vim editor.
#
# Standard POSIX only: compiles straight against the system libc with the
# host compiler (Apple clang). No EwokOS / ewoksys / libewoksys.a dependency.
# Objects and the final binary are produced in this directory.

CC      ?= cc
# gnu11 keeps the GNU extensions the sources rely on (e.g. the "?:" elvis
# operator in vim_input.c) while staying otherwise ISO C.
CFLAGS  ?= -O2 -std=gnu11 -Wall
LDFLAGS ?=

TARGET  := evim

SRCS := vim_util.c \
        vim_term.c \
        vim_input.c \
        vim_text.c \
        vim_cmd.c \
        vim_dcmd.c \
        vim_main.c \
        vim_syntax.c

OBJS := $(SRCS:.c=.o)
DEPS := vim.h vim_syntax.h

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS)

%.o: %.c $(DEPS)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

run: $(TARGET)
	./$(TARGET)
