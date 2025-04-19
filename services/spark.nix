{ config, lib, pkgs, ... }:

let
  cfg = config.services.spark;
in
{
  options = {
    services.spark = {
      enable = lib.mkEnableOption "Enable spark service";
      package = lib.mkPackageOption pkgs "spark_3_5" { };
      confDir = lib.mkOption {
        type = lib.types.path;
        default = pkgs.writeTextDir "log4j2.properties" cfg.log4j2Properties;
      };
      logDir = lib.mkOption {
        type = lib.types.str;
        default = "\${PWD}/.data/spark/logs";
      };
      masterWebuiPort = lib.mkOption {
        type = lib.types.int;
        default = 8085;
      };
      masterHost = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
      };
      workerWorkDir = lib.mkOption {
        type = lib.types.str;
        default = "\${PWD}/.data/spark/work";
      };

      log4j2Properties = lib.mkOption {
        type = lib.types.str;
        default = ''
          # Set everything to be logged to the console
          rootLogger.level = info
          rootLogger.appenderRef.stdout.ref = console

          # In the pattern layout configuration below, we specify an explicit `%ex` conversion
          # pattern for logging Throwables. If this was omitted, then (by default) Log4J would
          # implicitly add an `%xEx` conversion pattern which logs stacktraces with additional
          # class packaging information. That extra information can sometimes add a substantial
          # performance overhead, so we disable it in our default logging config.
          # For more information, see SPARK-39361.
          appender.console.type = Console
          appender.console.name = console
          appender.console.target = SYSTEM_ERR
          appender.console.layout.type = PatternLayout
          appender.console.layout.pattern = %d{yy/MM/dd HH:mm:ss} %p %c{1}: %m%n%ex

          # Set the default spark-shell/spark-sql log level to WARN. When running the
          # spark-shell/spark-sql, the log level for these classes is used to overwrite
          # the root logger's log level, so that the user can have different defaults
          # for the shell and regular Spark apps.
          logger.repl.name = org.apache.spark.repl.Main
          logger.repl.level = warn

          logger.thriftserver.name = org.apache.spark.sql.hive.thriftserver.SparkSQLCLIDriver
          logger.thriftserver.level = warn

          # Settings to quiet third party logs that are too verbose
          logger.jetty1.name = org.sparkproject.jetty
          logger.jetty1.level = warn
          logger.jetty2.name = org.sparkproject.jetty.util.component.AbstractLifeCycle
          logger.jetty2.level = error
          logger.replexprTyper.name = org.apache.spark.repl.SparkIMain$exprTyper
          logger.replexprTyper.level = info
          logger.replSparkILoopInterpreter.name = org.apache.spark.repl.SparkILoop$SparkILoopInterpreter
          logger.replSparkILoopInterpreter.level = info
          logger.parquet1.name = org.apache.parquet
          logger.parquet1.level = error
          logger.parquet2.name = parquet
          logger.parquet2.level = error

          # SPARK-9183: Settings to avoid annoying messages when looking up nonexistent UDFs in SparkSQL with Hive support
          logger.RetryingHMSHandler.name = org.apache.hadoop.hive.metastore.RetryingHMSHandler
          logger.RetryingHMSHandler.level = fatal
          logger.FunctionRegistry.name = org.apache.hadoop.hive.ql.exec.FunctionRegistry
          logger.FunctionRegistry.level = error

          # For deploying Spark ThriftServer
          # SPARK-34128: Suppress undesirable TTransportException warnings involved in THRIFT-4805
          appender.console.filter.1.type = RegexFilter
          appender.console.filter.1.regex = .*Thrift error occurred during processing of message.*
          appender.console.filter.1.onMatch = deny
          appender.console.filter.1.onMismatch = neutral
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    settings.processes = {
      spark-master = {
        command = "${cfg.package}/bin/start-master.sh";
        environment = {
          SPARK_MASTER_HOST = cfg.masterHost;
          SPARK_MASTER_WEBUI_PORT = toString cfg.masterWebuiPort;
          SPARK_NO_DAEMONIZE = "true";
          SPARK_CONF_DIR = toString cfg.confDir;
          SPARK_LOG_DIR = cfg.logDir;
        };
      };
      spark-worker = {
        command = "${cfg.package}/bin/start-worker.sh spark://${cfg.masterHost}:7077";
        environment = {
          SPARK_WORKER_DIR = cfg.workerWorkDir;
          SPARK_NO_DAEMONIZE = "true";
          SPARK_CONF_DIR = toString cfg.confDir;
          SPARK_LOG_DIR = cfg.logDir;
        };
      };
    };
  };
}
