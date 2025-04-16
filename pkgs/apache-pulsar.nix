{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "apache-pulsar";
  version = "4.0.4";

  src = fetchurl {
    url = "mirror://apache/pulsar/pulsar-${version}/apache-pulsar-${version}-bin.tar.gz";
    hash = "sha256-Jexhq1QYJX7lqq5JtK7bdlUe6u+WVYxP14KcKaQgPTw=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir $out
    tar --strip-components 1 -zxf $src -C $out
  '';
}
