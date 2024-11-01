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
        let
          inherit (pkgs) lib;
        in
        {
          packages =
            lib.pipe
              (lib.packagesFromDirectoryRecursive {
                inherit (pkgs) callPackage;
                directory = ./packages;
              })
              [
                (x: lib.removeAttrs x [ "docker" ])
                (lib.recursiveUpdate {
                  default = pkgs.callPackage ./packages/docker.nix {
                    inherit (self'.packages) app-source streamlit-runtime;
                  };
                })
              ];

          devshells.default = {
            env = [ ];
            commands = [
              {
                name = "build-and-push-x86";
                help = "Full pipeline";
                command = # bash
                  ''
                    set -x
                    snow spcs image-registry token --format=JSON --connection="ci-cd" | skopeo login $REGISTRY_URL --username 0sessiontoken --password-stdin
                    # snow spcs image-registry login
                    nix build .#packages.x86_64-linux.default

                    TAG="$REPOSITORY_URL/streamlit-spcs-scratch:latest"
                    skopeo copy \
                      --additional-tag "$TAG" \
                      --insecure-policy `#otherwise fails loading policy.json `\
                      docker-archive:result \
                      docker://"$TAG"

                  '';
              }
            ];
            packages = [ pkgs.skopeo ];
          };
        };

      flake = { };
    };
}
