# C++17 Project Template

A modern, production-grade **C++17** project template configured with automated compilation, unit testing, formatting, linting, memory sanitization, and native pre-commit hooks.

---

## Features

- **Modern C++17 Standard:** Compiles with `-std=c++17` under strict compiler flags (`-Wall -Wextra -Wpedantic -Werror -Wshadow -Wnon-virtual-dtor -Wconversion -Wsign-conversion -Wold-style-cast -Wnull-dereference -Wdouble-promotion -Wformat=2`).
- **Unit Testing (`doctest`):** Modern single-header testing framework with `TEST_CASE`, `SUBCASE`, and expressive assertions. Tests live in `tests/` and inline in `srcs/` behind `-DTESTING`.
- **Fast Sanitizers & Valgrind:** Includes an AddressSanitizer/UBSan target (`make asan`) for instant runtime error and memory leak detection at near-native speed, in addition to full Valgrind leak analysis (`make valgrind`).
- **Automated Formatting & Modernization:** Dynamically generates `.clang-format`, `.clang-tidy` (with `modernize-*` passes), and `.clangd` language server configurations.
- **Native Git Pre-Commit Hooks:** `make init` downloads `doctest.h` and installs the git hooks from `.scripts/` (style check + unit tests on every commit, conventional commit messages enforced).
- **Best Practice Idioms:** RAII, Rule of Zero / Rule of Five, `std::string_view`, scoped enums (`enum class`), and compile-time `constexpr` constants.

---

## Requirements

| Tool | Used by |
| :--- | :--- |
| `c++` (GCC / Clang, C++17) | building every target |
| `make` | build system |
| `curl` | `make init` (downloads `doctest.h`) |
| `clang-format` | `make format`, `make style`, `make check-style` |
| `clang-tidy` | `make style`, `make check-style`, `make fix-style` |
| `valgrind` | `make valgrind`, `make test` |
| `clang-check` *(optional)* | `make clang-check` static analyzer |
| `gprof` *(optional)* | `make gprof` profiling |

---

## Directory Structure

```text
├── Makefile                # Main build system (also generates the tooling configs)
├── README.md               # Project documentation
├── STYLE.md                # Coding standards and guidelines
├── .scripts/
│   ├── install-git-hooks.sh # Installs the hooks into .git/hooks
│   ├── pre-commit          # Runs check-style + doctest before each commit
│   └── commit-msg          # Enforces conventional commit messages
├── include/
│   ├── Harl.hpp            # Sample logging class header
│   ├── example.hpp         # Sample free-function header
│   └── external/
│       └── doctest.h       # Doctest single-header test framework (fetched by `make init`)
├── srcs/
│   ├── Harl.cpp            # Sample logging class implementation
│   ├── example.cpp         # Sample implementation + inline unit tests
│   └── main.cpp            # Entry point (normal build) / doctest main (test build)
├── tests/
│   └── example_test.cpp    # Standalone unit tests
└── build/                  # Object files (git-ignored)
```

Generated on demand and git-ignored: `.clang-format`, `.clang-tidy`, `.clangd`.

---

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repo-url> my-project
   cd my-project
   ```

2. **Initialize project (`doctest.h` + tooling configs + git hooks):**
   ```bash
   make init
   ```

3. **Run unit tests & memory check:**
   ```bash
   make test
   ```

4. **Build and run the application:**
   ```bash
   make run
   ```

---

## Build Targets

### Build & run

| Command | Description |
| :--- | :--- |
| `make` | Compiles the main executable (`a.out`). |
| `make run` | Executes the binary (`./a.out`). |
| `make exe` | Formats, then runs the binary wrapped in `time`. |
| `make debug` | Builds with debug symbols (`-g3 -O0`) and enabled logging, then runs it. |
| `make asan` | Builds the unit tests with AddressSanitizer + UndefinedBehaviorSanitizer and runs them (fails the build on any sanitizer report). |
| `make time` | Builds, then runs the binary under `time`. |
| `make valgrind` | Runs the executable wrapped in Valgrind with full leak checking. |
| `make gprof` | Rebuilds with `-pg`, runs the binary, and prints the `gprof` report. |

### Testing

| Command | Description |
| :--- | :--- |
| `make doctest` | Formats, builds, and runs the `doctest` unit test suite (`test_a.out`). |
| `make test` | Full gate: formats, builds and runs doctest, the debug binary, Valgrind on `a.out`, and the ASan binary. Exits non-zero if any step fails. |
| `make ctest` | `fclean` + `test` (a completely fresh run of the full gate). |

### Style & static analysis

| Command | Description |
| :--- | :--- |
| `make format` | Verifies header guards and formats all `.cpp`/`.hpp` files (including `tests/`). |
| `make style` | Reports formatting violations and runs `clang-tidy` analysis (use `check-style` for a failing CI gate). |
| `make check-style` | Non-mutating CI-style gate: formatting, `clang-tidy`, and header guards; exits non-zero on any violation. |
| `make fix-style` | Automatically applies `clang-tidy` fixes and reformats. |
| `make check-guards` | Verifies all headers have matching `#ifndef` include guards. |
| `make clang-check` | Runs the `clang-check --analyze` static analyzer. |
| `make clangd` | Generates `.clangd` (language server config, suppresses diagnostics in `doctest.h`). |

### Project setup & housekeeping

| Command | Description |
| :--- | :--- |
| `make init` | Generates `.clang-format`/`.clang-tidy`/`.clangd`, downloads `doctest.h`, and installs the git hooks. |
| `make clean` | Removes object files in `build/`. |
| `make fclean` | Removes object files and all compiled binaries (`a.out`, `test_a.out`, `debug_a.out`, `asan_a.out`). |
| `make re` | Rebuilds the project from scratch (`fclean` + `all`). |

### Variables

| Variable | Default | Description |
| :--- | :--- | :--- |
| `ARGS` | *(empty)* | Arguments passed to the application binaries by `run`, `exe`, `debug`, `time`, `valgrind`, `gprof`. |
| `TEST_ARGS` | *(empty)* | Arguments passed to the test binaries run by `doctest`, `asan`, and `test`. |
| `DEBUG_LEVEL` | `1` | Log threshold baked into the debug build (see Logging below). Objects are recompiled automatically when it changes. |
| `CC` | `c++` | Compiler front-end; override per invocation, e.g. `make CC=clang++`. |

```bash
make run ARGS="--input file.txt"
make doctest TEST_ARGS="--list-test-cases"
make debug DEBUG_LEVEL=3
```

---

## Testing Layout

Tests are written with `doctest` and are compiled only when `-DTESTING` is defined
(which `make doctest`, `make asan`, and `make test` do):

- `tests/*.cpp` — standalone test files, linked into `test_a.out` and `asan_a.out`.
- `srcs/*.cpp` — implementation files may contain their own tests inside `#ifdef TESTING` blocks.
- `srcs/main.cpp` — provides `main()` for the application normally, and the doctest runner under `TESTING`.

```bash
make doctest               # just the unit tests
./test_a.out --list-test-cases   # list them
```

---

## Logging (`Harl`)

`Harl::debug/info/warning/error` are static, header-only loggers:

- **Release build (`make`)**: `-DHARL` is not defined, the functions are empty inline stubs → logging is compiled out entirely.
- **Debug build (`make debug`, and the debug step of `make test`)**: `-DHARL=$(DEBUG_LEVEL)` enables the real implementations in `srcs/Harl.cpp`.

`DEBUG_LEVEL` is the **minimum** severity that gets printed (levels: `Debug=1`, `Info=2`, `Warning=3`, `Error=4`):

| `DEBUG_LEVEL` | Printed |
| :--- | :--- |
| `1` (default) | everything |
| `2` | `Info`, `Warning`, `Error` |
| `3` | `Warning`, `Error` |
| `4` | `Error` only |

---

## Git Hooks

`make init` installs two native hooks from `.scripts/`:

- **`pre-commit`**: runs `make check-style` (formatting + `clang-tidy` + header guards) and `make doctest`; the commit is rejected if either fails.
- **`commit-msg`**: enforces conventional commit messages — `type(scope): description`, where `type` is one of `feat`, `fix`, `test`, `style`, `docs`, `chore`, `perf`, `refactor`.

---

## Development Workflow

1. **Write Code:** Add headers under `include/` (using `#ifndef GUARD_HPP`) and source files under `srcs/`, tests under `tests/`.
2. **Format Regularly:** Run `make format` to format your code before committing.
3. **Run Fast Checks:** Use `make asan` for rapid feedback on test correctness and memory safety.
4. **Lint:** Run `make check-style` to verify modern C++17 guideline compliance (this is what the pre-commit hook runs).
5. **Commit Safely:** With `make init` installed, Git will validate style, tests, and the commit message format automatically.

See [STYLE.md](STYLE.md) for the full coding standards.

---

## Dependencies & Attribution

- This project uses `doctest.h` (fetched into `include/external/` by `make init`, currently v2.5.0).
```txt
Copyright (c) 2016-2023 Viktor Kirilov
Licensed under the MIT License
https://github.com/doctest/doctest
```
_____________
