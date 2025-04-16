{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "pulsar";
  version = "4.0.4";

  src = fetchurl {
    url = "mirror://apache/${pname}/${pname}-${version}/apache-${pname}-${version}-bin.tar.gz";
    hash = "sha256-Jexhq1QYJX7lqq5JtK7bdlUe6u+WVYxP14KcKaQgPTw=";
  };

  dontUnpack = true;

  installPhase = ''
    mkdir $out
    tar --strip-components 1 -zxf $src -C $out
  '';
}
