{
  description = "A `flake-parts` module for Rust development";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    crane.url = "github:ipetkov/crane";
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };
  outputs = { rust-overlay, crane, advisory-db, ... }:
    let
      # Preserve name and key of the module file for dedup and error message locations
      import' =
        modulePath: staticArg:
        {
          key = toString modulePath;
          _file = toString modulePath;
          imports = [ (import modulePath staticArg) ];
        };
    in
    {
      flakeModules = {
        default = import' ./nix/modules/flake-module.nix { inherit rust-overlay crane advisory-db; };
        nixpkgs = ./nix/modules/nixpkgs.nix;
      };
      nixci.default =
        let
          overrideInputs = {
            rust-flake = ./.;
          };
        in
        {
          dev = { inherit overrideInputs; dir = "dev"; };
        };
    };
}
