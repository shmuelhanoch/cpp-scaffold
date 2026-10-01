# cpp-scaffold

[![CI](https://github.com/shmuelhanoch/cpp-scaffold/actions/workflows/ci.yml/badge.svg)](https://github.com/shmuelhanoch/cpp-scaffold/actions/workflows/ci.yml)

A simple CLI for C++ new project generation, written in Janet. 

The CLI will generate the following project structure, were the tests rely on **[boost-ut](https://github.com/boost-ext/ut)**.

```
my-project/
├── CMakeLists.txt
├── flake.nix
├── .clang-format
├── README.md
├── include/
│   └── my-project/
│       └── my-project.hpp
├── src/
│   └── main.cpp
└── tests/
    ├── CMakeLists.txt
        └── test_main.cpp
```

## Getting Started

* Requires **[Janet](https://janet-lang.org/)**.

### Using Nix 

1. **Enter the Nix development shell:**
   ```bash
   nix develop
   ```
2. **Install project dependencies into the local tree:**
   ```bash
   jpm deps
   ```

3. **Build the executable:**
   ```bash
   jpm build
   ```

---

### Option 2: Manual Installation

If you already have Janet and `jpm` installed on your system:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/shmuelhanoch/cpp-scaffold.git
   cd cpp-scaffold
   ```

2. **Fetch dependencies and build:**
   ```bash
   jpm deps
   jpm build
   ```

3. **(Optional) Install system-wide or to `JANET_BINPATH`:**
   ```bash
   jpm install
   ```

---

## Usage

### Running the CLI

After building, the compiled binary will be located in the `./build/` directory:

```bash
./build/cpp-scaffold [OPTIONS] [PROJECT_NAME]
```

If installed globally via `jpm install` or within your active Nix shell environment, run directly:

```bash
cpp-scaffold [OPTIONS] [PROJECT_NAME]
```

### Getting Help

To view all available commands, options, and flags from the CLI help menu, run:

```bash
cpp-scaffold --help
```

or short-form:

```bash
cpp-scaffold -h
```
