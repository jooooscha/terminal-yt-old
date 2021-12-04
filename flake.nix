{
  description = "Workspace flake";

  inputs = {
    cargo2nix.url = "github:cargo2nix/cargo2nix";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-21.05";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, cargo2nix, flake-utils, rust-overlay, ... }:

    # Build the output set for each default system and map system sets into
    # attributes, resulting in paths such as:
    # nix build .#packages.x86_64-linux.<name>
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import "${cargo2nix}/overlay") rust-overlay.overlay ];
        pkgs = import nixpkgs {
          inherit overlays system;
        };

        rustPkgs = pkgs.rustBuilder.makePackageSet' {
          packageFun = import ./Cargo.nix;
          rustChannel = "1.56.1";
        };

        workspaceShell = rustPkgs.workspaceShell {
          buildInputs = with pkgs; [
            cargo-edit
            cargo-expand
            cargo-outdated
            cargo-watch

            nixpkgs-fmt
          ];
        };

      in
      rec {
        devShell = workspaceShell;

        packages = {
          cli = (rustPkgs.workspace.tyt { }).bin;
          core = (rustPkgs.workspace.core {});
          notification = (rustPkgs.workspace.notification {});
        };

        defaultPackage = packages.cli;
      }
    );
}