{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
  };

  outputs = { self, nixpkgs, flake-utils, naersk }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages."${system}";
        naersk-lib = naersk.lib."${system}";
      in
        rec {
          # `nix build`
          packages.tyt = naersk-lib.buildPackage {
            pname = "tyt";
            root = ./.;
          };
          defaultPackage = packages.tyt;

          # `nix run`
          apps.tyt = flake-utils.lib.mkApp {
            drv = packages.tyt;
          };
          defaultApp = apps.tyt;

          # `nix develop`
          devShell = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [ rustc cargo ];
          };
        }
    );
}
