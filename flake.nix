{
  inputs = {
    actions-nix.url = "github:nialov/actions.nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks-nix.url = "github:cachix/git-hooks.nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    pkgs-by-name-for-flake-parts.url = "github:drupol/pkgs-by-name-for-flake-parts";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
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
            flink = prev.flink.overrideAttrs (old: rec {
              pname = "flink";
              version = "1.17.1";

              src = pkgs.fetchurl {
                url = "mirror://apache/flink/${pname}-${version}/${pname}-${version}-bin-scala_2.12.tgz";
                sha256 = "sha256-HpVDS3ydi2Z1SINAUed9lni9i8FCr0SI8yBCYP4wxyM=";
              };

              installPhase =
                let
                  flinkTableApiScalaBridge = pkgs.fetchurl {
                    url = "mirror://maven/org/apache/flink/flink-table-api-scala-bridge_2.12/${version}/flink-table-api-scala-bridge_2.12-${version}.jar";
                    sha256 = "sha256-AphJidco/ws1bYS70vIai48qdGj7xqeDGST+kBekTRM=";
                  };
                  flinkTableApiScala = pkgs.fetchurl {
                    url = "mirror://maven/org/apache/flink/flink-table-api-scala_2.12/${version}/flink-table-api-scala_2.12-${version}.jar";
                    sha256 = "sha256-aY+J+ShZ+ubaFRk/cZzNsPJO1M0KvMUsuSAGZEnatXk=";
                  };
                in
                old.installPhase + ''
                  mv $out/opt/flink/opt/flink-sql-client* $out/opt/flink/lib/
                  mv $out/opt/flink/opt/flink-table-planner* $out/opt/flink/lib/
                  mv $out/opt/flink/lib/flink-table-planner-loader* $out/opt/flink/opt/
                  ln -s ${flinkTableApiScalaBridge} $out/opt/flink/lib/
                  ln -s ${flinkTableApiScala} $out/opt/flink/lib/
                '';
            });
          })
        ];
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [
          config.pre-commit.devShell
        ];
      };

      pre-commit.settings.hooks = {
        deadnix.enable = true;
        flake-checker.enable = true;
        markdownlint.enable = true;
        nixpkgs-fmt.enable = true;
        statix.enable = true;
      };

      pkgsDirectory = ./pkgs;

      process-compose.notebook = {
        imports = [ ./services/zeppelin.nix ];

        services.zeppelin.enable = true;
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
