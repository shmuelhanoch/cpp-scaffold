# %1$s

A modern C++%2$s header-only library.

## Requirements

- Nix with Flakes enabled (or a C++%2$s compiler and CMake)

## Building & Testing

Run tests instantly via Nix flake:

```sh
nix flake check
```

Or enter the development shell to run CMake manually:

```
nix develop
cmake -B build -S .
cmake --build build
ctest --test-dir build --output-on-failure
```
