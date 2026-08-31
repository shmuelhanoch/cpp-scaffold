{
  description = "Minimal C++ development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Systems supported (Linux & macOS, Intel & Apple Silicon)
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      
      # Standard nixpkgs helper to map over systems without extra flake-utils dependencies
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # Force Clang toolchain consistently across macOS and Linux
          stdenv = pkgs.clangStdenv;
        in
        {
          default = pkgs.mkShell.override { inherit stdenv; } {
            # Build tools and developer dependencies
            nativeBuildInputs = with pkgs; [
              cmake
              ninja
              clang-tools # clangd, clang-format, clang-tidy
            ];

            # Ensure Clang is set as default in the shell environment
            shellHook = ''
              export CC=clang
              export CXX=clang++
            '';
          };
        }
      );
    };
}
