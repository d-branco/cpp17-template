# Coding Standards and Guidelines

This document outlines the coding standards, best practices, and guidelines for this modern **C++17** repository.

---

## 1. Core Principles

- **Language Standard:** Strict C++17 (`-std=c++17`).
- **Resource Management:** Strict adherence to **RAII** (Resource Acquisition Is Initialization). Manual memory management (`new`/`delete`) is discouraged; use standard containers and smart pointers (`std::unique_ptr`, `std::shared_ptr`).
- **Class Lifecycle:** Follow the **Rule of Zero** (prefer classes that require no custom destructor, copy, or move operations). When managing manual resources, adhere to the **Rule of Five** using `= default` or `= delete` where appropriate.
- **Include Guards:** Classic preprocessor header guards are preferred over `#pragma once` for maximum ISO C++ portability.

---

## 2. Include Directives & Header Guards

### Header Guards
All header files (`.hpp`) must be protected by standard preprocessor guards matching the uppercase filename:
```cpp
#ifndef HARL_HPP
#define HARL_HPP

// Declarations...

#endif // HARL_HPP
```
The build system verifies all include guards automatically via `make check-guards`.

### Include What You Use (IWYU)
- Every `.cpp` file should directly include the headers providing the declarations it utilizes.
- Headers should include only what is necessary for their own declarations, using forward declarations where possible.

---

## 3. C++17 Idioms & Best Practices

1. **Null Pointers:** Always use `nullptr`. `NULL` and `0` for pointers are forbidden.
2. **String Passing:** Prefer `std::string_view` for read-only string parameters to prevent unnecessary heap allocations for string literals and substrings.
3. **Scoped Enums:** Use `enum class` with an explicit underlying type (e.g., `std::uint8_t`) rather than legacy unscoped C-style enums:
   ```cpp
   enum class LogLevel : std::uint8_t
   {
       Debug = 1,
       Info = 2,
       Warning = 3,
       Error = 4
   };
   ```
4. **Compile-time Constants:** Prefer `constexpr` (or `inline constexpr`) over preprocessor `#define` directives for constants and colors.
5. **Type Deduction & Structured Bindings:** Use `auto` when the type is obvious from the right-hand side or when handling complex iterator types. Leverage structured bindings where applicable.
6. **Attributes:** Use standard attributes such as `[[nodiscard]]` on functions whose return value signifies status or handles that must not be discarded.
7. **Type Casting:** Never use C-style casts. Use `static_cast`, `reinterpret_cast`, or `const_cast`. The build system enforces `-Wold-style-cast`.

---

## 4. Naming Conventions

- **Classes / Structs / Enums:** `UpperCamelCase` (e.g., `Harl`, `LogLevel`).
- **Functions & Methods:** `lower_case` or `snake_case` (e.g., `debug`, `get_status`).
- **Variables & Parameters:** `snake_case` (e.g., `msg`, `log_level`).
- **Private Member Variables:** `snake_case_` with trailing underscore (e.g., `count_`).
- **Constants / Enum Values:** `UpperCamelCase` or `SCREAMING_SNAKE_CASE` (e.g., `Debug`, `MAX_RETRIES`).
- **Filenames:** Match the primary class or utility name (`Harl.hpp`, `Harl.cpp`, `main.cpp`).

---

## 5. Formatting & Tooling

Formatting and linting rules are enforced via LLVM tooling:
- **Braces:** Allman style (opening and closing braces on their own lines).
- **Indentation:** 4 spaces (no tabs).
- **Line Length:** Maximum 100 columns.
- **Dynamic Configs:** The `Makefile` generates `.clang-format`, `.clang-tidy`, and `.clangd` dynamically.

### Useful Commands
- **Check Include Guards:** `make check-guards`
- **Format Code:** `make format`
- **Lint Code (Clang-Tidy):** `make style`
- **Auto-Fix Lint Issues:** `make fix-style`
- **Install Git Hook:** `make hooks`

---

## 6. Testing & Memory Verification

- **Unit Testing:** Unit tests are built with `doctest`. Tests are active when `-DTESTING` is supplied.
- **AddressSanitizer (`make asan`):** Compiles and runs tests using `-fsanitize=address,undefined -fno-omit-frame-pointer -g3` for instant detection of memory leaks, buffer overflows, and undefined behavior.
- **Valgrind (`make valgrind`):** Executes full leak check analysis with `--leak-check=full --track-origins=yes`.
- **Integrated Test Target (`make test`):** Executes unit tests, debug runs, and valgrind memory leak verification in a single command.
