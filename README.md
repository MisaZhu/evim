# evim

A small, fast, dependency-free **vi/vim** editor that builds natively on macOS
and any POSIX system. `evim` is a modern port of the classic *tiny vi* clone:
it keeps the full modal-editing ergonomics of `vi`, adds **charwise visual
selection** and **line-oriented syntax highlighting**, and compiles straight
against the system C library with the host compiler — no external libraries, no
terminal framework, no runtime dependencies.

```
Version: 0.9.1-vim
Binary:  evim
License: see LICENSE
```

---

## Why evim

- **Zero dependencies.** Pure POSIX C compiled with Apple clang (or any `cc`)
  against the system libc. Nothing to install, nothing to link, nothing to
  configure.
- **Instant build.** A single `make` produces the `evim` binary in seconds.
- **Tiny and fast.** The whole editor is a handful of C files. It starts
  immediately, edits large buffers in memory, and repaints only the screen
  columns that actually changed.
- **Real vi muscle memory.** Modal editing, motions, operators, counts, marks,
  registers, search, undo and the full `:ex` command line all behave the way a
  `vi` user expects.
- **Modern touches on a classic core.** Charwise visual selection (`v`),
  bracket matching, and color syntax highlighting for JSON, JavaScript, C/C++,
  `.conf` and `.rd` files.
- **Portable terminal handling.** Probes the real window geometry, speaks
  standard VT100/xterm escape sequences, and cleanly restores the terminal on
  exit (even on crashes, via `atexit` and `setjmp`).

---

## Build & run

Requires a C compiler and `make` (Xcode command line tools on macOS).

```sh
make          # build ./evim
make run      # build and launch ./evim
make clean    # remove object files and the binary
```

The build uses `-O2 -std=gnu11 -Wall`. Compiler and flags can be overridden:

```sh
make CC=clang CFLAGS="-O3 -std=gnu11 -Wall"
```

### Usage

```sh
./evim                 # start editing an empty buffer
./evim file.txt        # edit one file
./evim a.txt b.txt     # edit several files (:n / :prev / :rewind to move)
```

---

## Feature overview

### Editing modes
- **Command (normal) mode** — motions, operators and `:ex` commands.
- **Insert mode** — `i`, `I`, `a`, `A`, `o`, `O`, `s`, `c`, `C`, `Insert` key.
- **Replace mode** — `R` overwrites characters in place; toggle with `Insert`.
- **Visual mode** — `v` starts a charwise selection; motions extend it and
  operators apply to the whole highlighted range.

### Motions & navigation
- Character/line: `h j k l`, arrow keys, `Space`, `Enter`, `+`, `-`, `Home`,
  `End`, `0`, `^`, `$`, `|`.
- Word: `w`, `W`, `b`, `B`, `e`, `E`.
- Screen/file: `H`, `M`, `L`, `G`, `gg`, `{`, `}` (paragraphs), `%`
  (matching `()[]{}` bracket).
- Character search on a line: `f`, `F`, `t`, `T`, repeat with `;` and `,`.
- Scrolling: `Ctrl-B` / `PageUp`, `Ctrl-F` / `PageDown`, `Ctrl-D`, `Ctrl-U`,
  `Ctrl-E`, `Ctrl-Y`; reposition current line with `z.`, `z-`, `z<CR>`.
- Redraw with `Ctrl-L` / `Ctrl-R`; show file status with `Ctrl-G`.

### Text objects & operators
- Change / delete / yank with a motion: `c`, `d`, `y` (e.g. `dw`, `cw`, `d$`,
  `yG`).
- Line-wise: `C`, `D`, `Y`, `dd`, `cc`, `yy` with counts.
- `x` / `X` / `Del` delete a character, `s` substitutes one, `J` joins lines,
  `~` flips case, `r` replaces a single character.
- `<` / `>` shift a range left or right (by tab / `tabstop` spaces).

### Yank, delete & registers
- Put with `p` (after) and `P` (before), honoring line-wise vs. char-wise text.
- 26 named registers `a`–`z` selectable with `"` before any yank/delete/put.
- A dedicated register powers the `U` "restore original line" command.

### Marks & context
- Set marks with `m{a-z}`, jump to a mark with `'{a-z}`.
- `''` swaps between the current and previous cursor context.

### Search
- `/pattern` forward, `?pattern` backward, repeat with `n` / `N`.
- Searches wrap around the file and report "search hit BOTTOM/TOP".
- Honors the `ignorecase` option.

### Undo & repeat
- `u` undoes the last operation (full undo stack with insert/delete chaining).
- `U` restores the current line to its original content.
- `.` repeats the last modifying command, including its count.
- Numeric prefixes (`1`–`9`) multiply almost any motion or operator.

### Multiple files
- Pass several filenames on the command line.
- Move between them with `:n` (next), `:prev` (previous) and `:rewind`.
- `ZZ` saves (if modified) and advances to the next file.

### Syntax highlighting
Color highlighting is chosen automatically from the file extension:

| Extension                                   | Language                 |
| ------------------------------------------- | ------------------------ |
| `.json`                                     | JSON                     |
| `.js`                                       | JavaScript               |
| `.c`, `.h`, `.cc`, `.cpp`, `.cxx`, `.hpp`   | C / C++                  |
| `.conf`                                     | key = value config files |
| `.rd`                                       | init/run scripts         |

The highlighter is **line-oriented**: colors are a pure function of each line's
text, so it stays correct while only the changed screen columns are repainted.
It distinguishes strings, keys/keywords, numbers, literals, braces, comments,
commands, paths and operators, and the visual selection is shown in reverse
video on top of the token colors.

### Status line
A live status line reports the filename, cursor position, buffer size,
modification state and command feedback (yank/delete/put sizes, substitution
counts, errors and more).

---

## `:ex` (colon) commands

Addresses may precede any command: line numbers (`:12`), `.` (current), `$`
(last), `%` (whole file), marks (`:'a`), patterns (`:/pat/`, `:?pat?`) and
offsets (`+`, `-`), combined into ranges (`:4,33`).

| Command                    | Action                                             |
| -------------------------- | -------------------------------------------------- |
| `:w [file]`, `:w!`         | write the buffer (force-overwrite an existing file) |
| `:wq`, `:wn`, `:x`         | write then quit / next                              |
| `:q`, `:q!`                | quit (ignore unsaved changes with `!`)              |
| `:e [file]`, `:e!`         | edit a file (discard changes with `!`)              |
| `:r file`                  | read a file into the buffer at the address          |
| `:n`, `:prev`, `:rewind`   | next / previous / rewind the argument file list     |
| `:d`                       | delete the addressed lines                          |
| `:y`                       | yank the addressed lines into the register          |
| `:s/find/replace/[g]`      | substitute (global with `g`), over any range        |
| `:set ...`                 | set editor options (see below)                      |
| `:list`                    | print the addressed lines literally                 |
| `:file [name]`             | show status, or rename the current file             |
| `:=`                       | print the addressed line number                     |
| `:version`                 | show the editor version                             |

`ZZ` is a normal-mode shortcut for "save if modified, then exit".

---

## Options (`:set`)

Run `:set` or `:set all` to print current values. Prefix a boolean with `no` to
disable it.

| Option                     | Short | Effect                                       |
| -------------------------- | ----- | -------------------------------------------- |
| `autoindent`               | `ai`  | indent new lines to match the previous line   |
| `expandtab`                | `et`  | expand typed tabs into spaces                 |
| `flash`                    | `fl`  | signal errors with a screen flash, not a beep |
| `ignorecase`               | `ic`  | case-insensitive search                       |
| `showmatch`                | `sm`  | briefly flash the matching bracket            |
| `tabstop=N`                | `ts`  | set the tab width (1–32, default 8)           |

Example:

```
:set ai et ts=4 noic
```

### Startup file
On launch `evim` reads an `.exrc` file (if present) and runs its lines as `:ex`
commands, so options can be preset before editing begins.

---

## Project layout

| File              | Responsibility                                             |
| ----------------- | ---------------------------------------------------------- |
| `vim.h`           | shared constants, globals and prototypes                    |
| `vim_main.c`      | entry point, raw tty mode, per-file editing loop            |
| `vim_input.c`     | keyboard input, escape-sequence decoding, key timeouts      |
| `vim_term.c`      | screen geometry probing, virtual screen, repaint/refresh    |
| `vim_text.c`      | text buffer, undo stack, registers, yank/delete primitives  |
| `vim_dcmd.c`      | normal-mode command dispatch (`do_cmd`) and visual mode     |
| `vim_cmd.c`       | `:ex`/colon command parsing and execution                   |
| `vim_syntax.c/.h` | line-oriented syntax highlighting                           |
| `vim_util.c`      | shared utility helpers                                      |
| `Makefile`        | native build rules                                          |

---

## Origins & attribution

`evim` derives from the classic **tiny vi** clone:

> tiny vi.c: A small "vi" clone
> Copyright (C) 2000, 2001 Sterling Huxley
> Licensed under GPLv2 or later.
> Adapted for Raspberry Pi, 2021 lurk101.

This port removes the original embedded-OS dependency, builds against standard
POSIX on macOS/Linux, and adds the charwise visual selection mode and the
JSON / JavaScript / C / `.conf` / `.rd` syntax highlighting described above.

## License

See the [`LICENSE`](LICENSE) file in this repository.
