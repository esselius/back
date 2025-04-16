{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    actions-nix.url = "github:nialov/actions.nix";
  };

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "aarch64-darwin" ];

    imports = [
      inputs.git-hooks-nix.flakeModule
      inputs.actions-nix.flakeModules.actions-nix
    ];

    perSystem = { config, ... }: {
      devShells.default = config.pre-commit.devShell;
      pre-commit.settings.hooks = {
        nixpkgs-fmt.enable = true;
        statix.enable = true;
        deadnix.enable = true;
        flake-checker.enable = true;
      };
    };

    flake.actions-nix = {
      pre-commit.enable = true;
      workflows = {
        ".github/workflows/main.yaml" = {
          jobs = {
            nix-flake-check = {
              runs-on = "ubuntu-latest";
              timeout-minutes = 60;
              steps = [
                { uses = "actions/checkout@v4"; }

                inputs.actions-nix.lib.steps.DeterminateSystemsNixInstallerAction

                { run = "nix -Lv flake check"; }
              ];
            };
          };
        };
      };
    };
  };
}
