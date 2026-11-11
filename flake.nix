{
  description = "skillforge dev shell (toolchain from rust-toolchain.toml)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    # The store guard of the canon (exobrain): `exobrain store-guard --daily`
    # in .envrc warns about working-tree copies in the Nix store.
    exobrain-tech = {
      url = "github:gubasso/exobrain-tech/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      flake-utils,
      exobrain-tech,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };
        # cargo, rustc, clippy, and rustfmt, read from the channel and the
        # components of rust-toolchain.toml, the one version declaration that
        # rustup, a bare cargo, and rust-analyzer also read.
        toolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            toolchain
          ]
          # exobrain, the store guard that .envrc runs once a day. exobrain-tech
          # builds it for x86_64-linux alone, so the other systems keep their shell.
          ++ pkgs.lib.optionals (system == "x86_64-linux") [
            exobrain-tech.packages.${system}.default
          ];
        };
      }
    );
}
