{
  description = "Description for the project";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs.follows = "nixpkgs-stable";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    stub.url = "github:VTimofeenko/stub-flake";

  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      imports = [
        inputs.devshell.flakeModule
      ];

      perSystem =
        {
          pkgs,
          self',
          # These inputs are unused in the template, but might be useful later
          # , config
          # , inputs'
          # , system
          ...
        }:
        {
          packages =
            (pkgs.lib.packagesFromDirectoryRecursive {
              inherit (pkgs) callPackage;
              directory = ./packages;
            });

          devshells.default = {
            env = [ ];
            commands = [
              {
                name = "";
                help = "";
                command = "";
              }
            ];
          };
        };

      flake = { };
    };
}
