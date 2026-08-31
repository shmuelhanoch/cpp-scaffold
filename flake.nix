{
  description = "C++ Scaffold CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Helper to generate outputs for multiple architectures
      supportedSystems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = [
              pkgs.janet
              pkgs.jpm
              pkgs.stdenv.cc
              pkgs.git
            ];

            shellHook = ''
              export JANET_TREE="$PWD/.jpm_tree"
              export JANET_PATH="$JANET_TREE/lib"
              export JANET_BINPATH="$JANET_TREE/bin"
              export PATH="$JANET_BINPATH:$PATH"

              mkdir -p "$JANET_TREE"
              echo "🛠️  cpp-scaffold dev environment loaded (Janet + jpm)"
            '';
          };
        }
      );
    };
}
