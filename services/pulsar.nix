{ config, lib, pkgs, ... }:
let
  cfg = config.services.pulsar;
in
{
  options = {
    services.pulsar = {
      enable = lib.mkEnableOption "Enable pulsar service";
      package = lib.mkPackageOption pkgs "apachePulsar" { };
      logDir = lib.mkOption {
        type = lib.types.str;
        default = "\${PWD}/.data/pulsar/logs";
      };
      clusterName = lib.mkOption {
        type = lib.types.str;
        default = "myCluster";
      };
      # port = lib.mkOption {
      #   type = lib.types.port;
      #   default = 8084;
      # };
      config = lib.mkOption {
        type = lib.types.path;
        default = pkgs.writeText "pulsar-config" (builtins.replaceStrings
          [
            "clusterName="
            "metadataStoreUrl="
          ]
          [
            "clusterName=${cfg.clusterName}"
            "metadataStoreUrl=zk:localhost:2181"
          ]
          (builtins.readFile "${cfg.package}/conf/broker.conf"));
      };
    };
  };
  config = lib.mkIf cfg.enable {
    settings.processes.pulsar-init = {
      # command = "${cfg.package}/bin/pulsar standalone --metadata-dir \${PWD}/.data/pulsar/metadata --bookkeeper-dir \${PWD}/.data/pulsar/bookeeper";
      command = "${cfg.package}/bin/pulsar initialize-cluster-metadata --cluster=${cfg.clusterName} --metadata-store=zk:localhost:2181 --web-service-url=http://localhost:8080 --configuration-metadata-store=zk:localhost:2181";
      # working_dir = ".data/pulsar";
      depends_on.z1.condition = "process_healthy";
      environment = {
        PULSAR_LOG_DIR = cfg.logDir;
        PULSAR_BROKER_CONF = toString cfg.config;
      };
    };
    settings.processes.pulsar-broker = {
      # command = "${cfg.package}/bin/pulsar standalone --metadata-dir \${PWD}/.data/pulsar/metadata --bookkeeper-dir \${PWD}/.data/pulsar/bookeeper";
      command = "${cfg.package}/bin/pulsar broker";
      # working_dir = ".data/pulsar";
      depends_on.pulsar-init.condition = "process_completed_successfully";
      environment = {
        PULSAR_LOG_DIR = cfg.logDir;
        PULSAR_BROKER_CONF = toString cfg.config;
      };
    };
  };
}
