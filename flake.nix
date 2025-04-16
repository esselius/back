{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
  };

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "aarch64-darwin" ];

    imports = [
      inputs.git-hooks-nix.flakeModule
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
  };
}
