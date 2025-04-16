{
  inputs = {
    actions-nix.url = "github:nialov/actions.nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    just-flake.url = "github:juspay/just-flake";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
  };

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "aarch64-darwin" "x86_64-linux" ];

    imports = [
      inputs.actions-nix.flakeModules.actions-nix
      inputs.git-hooks-nix.flakeModule
      inputs.just-flake.flakeModule
      inputs.pkgs-by-name-for-flake-parts.flakeModule
    ];

    perSystem = { config, pkgs, ... }: {
      devShells.default = pkgs.mkShell {
        inputsFrom = [
          config.pre-commit.devShell
          config.just-flake.outputs.devShell
        ];
      };

      pre-commit.settings.hooks = {
        deadnix.enable = true;
        flake-checker.enable = true;
        markdownlint.enable = true;
        nixpkgs-fmt.enable = true;
        statix.enable = true;
      };

      just-flake.features = {
        build = {
          enable = true;
          justfile = ''
            build:
              nix build --no-link .#apache-pulsar
          '';
        };
      };

      pkgsDirectory = ./pkgs;
    };

    flake.actions-nix = {
      pre-commit.enable = true;

      workflows.".github/workflows/main.yaml" = {
        jobs.nix-flake-check = {
          runs-on = "ubuntu-latest";
          timeout-minutes = 60;
          steps = with inputs.actions-nix.lib.steps; [
            actionsCheckout
            DeterminateSystemsNixInstallerAction
            runNixFlakeCheck
          ];
        };
      };
    };
  };
}
