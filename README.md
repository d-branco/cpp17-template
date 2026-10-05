# C++17 Project Template

A modern, production-grade **C++17** project template configured with automated compilation, unit testing, formatting, linting, memory sanitization, and native pre-commit hooks.

---

## Features

- **Modern C++17 Standard:** Compiles with `-std=c++17` under strict compiler flags (`-Wall -Wextra -Wpedantic -Werror -Wshadow -Wnon-virtual-dtor -Wconversion -Wsign-conversion -Wold-style-cast -Wnull-dereference -Wdouble-promotion -Wformat=2`).
- **Upgraded Unit Testing (`doctest`):** Modern single-header testing framework with `TEST_CASE`, `SUBCASE`, and expressive assertions.
- **Fast Sanitizers & Valgrind:** Includes an AddressSanitizer/UBSan target (`make asan`) for instant runtime error and memory leak detection at near-native speed, in addition to full Valgrind leak analysis (`make valgrind`).
- **Automated Formatting & Modernization:** Dynamically generates `.clang-format`, `.clang-tidy` (with `modernize-*` passes), and `.clangd` language server configurations.
- **Native Git Pre-Commit Hooks & Submodule:** Project initialization (`make init`) downloads `doctest` as a git submodule, updates its single-header file, and installs git hooks.
- **Best Practice Idioms:** RAII, Rule of Zero / Rule of Five, `std::string_view`, scoped enums (`enum class`), and compile-time `constexpr` constants.

---

## Directory Structure

```text
├── Makefile                # Main build system
├── README.md               # Project documentation
├── .scripts/               # Install scripts for git hooks and doctest
├── include/
│   ├── Harl.hpp            # Sample class header
│   ├── header.hpp          # Common/testing configuration header
│   └── external/
│       └── doctest.h       # Doctest single-header test framework
└── srcs/
    ├── Harl.cpp            # Sample class implementation
    └── main.cpp            # Application entry point and unit tests
```

---

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repo-url> my-project
   cd my-project
   ```

2. **Initialize project (submodules & hooks):**
   ```bash
   make init
   ```

3. **Run unit tests & memory check:**
   ```bash
   make test
   ```
   Or run the fast AddressSanitizer test:
   ```bash
   make asan
   ```

4. **Build and run the application:**
   ```bash
   make run
   ```

---

## Build Targets

| Command | Description |
| :--- | :--- |
| `make` | Compiles the main executable (`a.out`). |
| `make run` | Compiles and executes the binary (`./a.out`). |
| `make debug` | Compiles with debug symbols (`-g3`, `-O0`) and active logging. |
| `make asan` | Compiles with AddressSanitizer + UndefinedBehaviorSanitizer and runs tests. |
| `make doctest` | Compiles and runs the `doctest` unit test suite. |
| `make valgrind` | Runs the executable wrapped in Valgrind with full leak checking. |
| `make test` | Comprehensive target: formats, builds, runs doctest, debug, and Valgrind. |
| `make format` | Formats all `.cpp` and `.hpp` files using `clang-format`. |
| `make style` | Checks code formatting and runs `clang-tidy` analysis. |
| `make fix-style` | Automatically applies `clang-tidy` fixes and reformats. |
| `make check-guards` | Verifies all headers have matching `#ifndef` include guards. |
| `make init` | Initializes the `doctest` submodule, copies `doctest.h`, and installs git hooks. |
| `make clean` | Removes object files in `build/`. |
| `make fclean` | Removes object files and all compiled binaries. |
| `make re` | Rebuilds the project from scratch (`fclean` + `all`). |

---

## Development Workflow

1. **Write Code:** Add headers under `include/` (using `#ifndef GUARD_HPP`) and source files under `srcs/`.
2. **Format Regularly:** Run `make format` to format your code before committing.
3. **Run Fast Checks:** Use `make asan` for rapid feedback on test correctness and memory safety.
4. **Lint:** Run `make style` to verify modern C++17 guideline compliance.
5. **Commit Safely:** With `make init` installed, Git will automatically validate conventional commit message formatting.

---

## Dependencies & Attribution
- This project uses `doctest.h` (included in the `include/external/` directory).
```txt
Copyright (c) 2016-2018 Viktor Kirilov
Licensed under the MIT License
https://github.com/onqtam/doctest
```
_____________
