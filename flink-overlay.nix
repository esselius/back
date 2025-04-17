_: prev:

let
  version = "1.17.1";

  flinkTableApiScalaBridge = prev.fetchurl {
    url = "mirror://maven/org/apache/flink/flink-table-api-scala-bridge_2.12/${version}/flink-table-api-scala-bridge_2.12-${version}.jar";
    sha256 = "sha256-AphJidco/ws1bYS70vIai48qdGj7xqeDGST+kBekTRM=";
  };

  flinkTableApiScala = prev.fetchurl {
    url = "mirror://maven/org/apache/flink/flink-table-api-scala_2.12/${version}/flink-table-api-scala_2.12-${version}.jar";
    sha256 = "sha256-aY+J+ShZ+ubaFRk/cZzNsPJO1M0KvMUsuSAGZEnatXk=";
  };
in
{
  flink = prev.flink.overrideAttrs (old: {
    inherit version;

    src = prev.fetchurl {
      url = "mirror://apache/flink/flink-${version}/flink-${version}-bin-scala_2.12.tgz";
      sha256 = "sha256-HpVDS3ydi2Z1SINAUed9lni9i8FCr0SI8yBCYP4wxyM=";
    };

    installPhase =
      old.installPhase + ''
        mv $out/opt/flink/opt/flink-sql-client* $out/opt/flink/lib/
        mv $out/opt/flink/opt/flink-table-planner* $out/opt/flink/lib/
        mv $out/opt/flink/lib/flink-table-planner-loader* $out/opt/flink/opt/

        ln -s ${flinkTableApiScalaBridge} $out/opt/flink/lib/
        ln -s ${flinkTableApiScala} $out/opt/flink/lib/
      '';
  });
}
