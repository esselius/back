{ lib, stdenv, fetchurl, makeWrapper, jdk11, coreutils, findutils, gnugrep, gawk, gnused, hostname, flink }:

stdenv.mkDerivation rec {
  pname = "zeppelin";
  version = "0.12.0";

  src = fetchurl {
    url = "https://dlcdn.apache.org/${pname}/${pname}-${version}/${pname}-${version}-bin-all.tgz";
    hash = "sha256-Oh1+BU0oEFAlcexJcLINy7JaPtbKOic4/dHYLDgbvhw=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir $out
    tar --strip-components 1 -zxf $src -C $out

    wrapProgram $out/bin/zeppelin.sh \
      --set JAVA_HOME "${jdk11.home}" \
      --set PATH "${lib.makeBinPath [coreutils findutils gnugrep gawk gnused hostname]}" \
      --set FLINK_HOME "${flink}/opt/flink"
  '';
}
