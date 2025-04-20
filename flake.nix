{
  inputs = {
    actions-nix.url = "github:nialov/actions.nix";
    actions-nix.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    git-hooks-nix.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    services-flake.url = "github:juspay/services-flake";
  };

  outputs = inputs@{ flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "aarch64-darwin" "x86_64-linux" ];

    imports = [
      inputs.actions-nix.flakeModules.actions-nix
      inputs.git-hooks-nix.flakeModule
      inputs.pkgs-by-name-for-flake-parts.flakeModule
      inputs.process-compose-flake.flakeModule
    ];

    perSystem = { config, pkgs, system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          (_: prev: {
            zeppelin = prev.callPackage ./pkgs/zeppelin.nix { };
            flink_1_17 = prev.callPackage ./pkgs/flink_1_17.nix { };
            apachePulsar = prev.callPackage ./pkgs/apachePulsar.nix { };
          })
        ];
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [ config.pre-commit.devShell ];
        packages = [ pkgs.watchexec pkgs.pulsarctl ];
        shellHook = config.pre-commit.installationScript;
      };

      pre-commit.settings.hooks = {
        deadnix.enable = true;
        flake-checker.enable = true;
        markdownlint.enable = true;
        nixpkgs-fmt.enable = true;
        statix.enable = true;
      };

      pkgsDirectory = ./pkgs;

      process-compose.notebook =
        let
          inherit (inputs.services-flake.lib) multiService;
        in
        {
          imports = [
            inputs.services-flake.processComposeModules.default
            (multiService ./services/flink.nix)
            (multiService ./services/pulsar.nix)
            (multiService ./services/spark.nix)
            (multiService ./services/zeppelin.nix)
          ];

          services = {
            flink.flink.enable = true;
            pulsar.pulsar.enable = true;
            spark.spark.enable = true;
            zeppelin.zeppelin = {
              enable = true;
              useFlink = true;
              useSpark = true;
            };
            zookeeper.zookeeper.enable = true;
          };
        };
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
