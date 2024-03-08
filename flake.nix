{
  description = "A devShell example";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
    nocargo = {
      # Once https://github.com/oxalica/nocargo/pull/17 merges we can
      # use the upstream oxalica/nocargo
      # url = "github:o-santi/nocargo";
      url = "github:therishidesai/nocargo/rdesai/resolver-v2-and-version-parsing";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.registry-crates-io.follows = "registry-crates-io";
    };
    registry-crates-io = { url = "github:rust-lang/crates.io-index"; flake = false; };
  };

  outputs = { self, nixpkgs, nocargo, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        ws = nocargo.lib.${system}.mkRustPackageOrWorkspace {
          src = ./.;
        };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          nativeBuildInputs = [
            rust-bin.nightly.latest.default
          ];
        };

        packages = ws.release;
      }
    );
}
