{ config, lib, pkgs, name, ... }:
{
  options = {
    package = lib.mkPackageOption pkgs "apachePulsar" { };
    logDir = lib.mkOption {
      type = lib.types.str;
      default = "\${PWD}/${config.dataDir}/logs";
    };
    clusterName = lib.mkOption {
      type = lib.types.str;
      default = "myCluster";
    };
    config = lib.mkOption {
      type = lib.types.path;
      default = pkgs.writeText "pulsar-config" (builtins.replaceStrings
        [
          "clusterName="
          "metadataStoreUrl="
        ]
        [
          "clusterName=${config.clusterName}"
          "metadataStoreUrl=zk:localhost:2181"
        ]
        (builtins.readFile "${config.package}/conf/broker.conf"));
    };
  };
  config = {
    outputs.settings.processes = {
      "${name}-init" = {
        command = "${config.package}/bin/pulsar initialize-cluster-metadata --cluster=${config.clusterName} --metadata-store=zk:localhost:2181 --web-service-url=http://localhost:8080 --configuration-metadata-store=zk:localhost:2181";
        environment = {
          PULSAR_LOG_DIR = config.logDir;
          PULSAR_BROKER_CONF = toString config.config;
        };
      };
      "${name}-broker" = {
        command = "${config.package}/bin/pulsar broker";
        environment = {
          PULSAR_LOG_DIR = config.logDir;
          PULSAR_BROKER_CONF = toString config.config;
        };
      };
    };
  };
}
