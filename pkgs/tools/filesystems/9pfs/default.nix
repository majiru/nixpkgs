{ lib, stdenv, fetchFromGitHub, pkg-config, fuse }:

stdenv.mkDerivation rec {
  pname = "9pfs";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "ftrvxmtrx";
    repo = "9pfs";
    rev = version;
    sha256 = "sha256-mLRpVWCNphzc7TVEOQ/IMpnzibDdiQZV6MVfAlm7+vM=";
  };

  makeFlags = [ "BIN=$(out)/bin" "MAN=$(out)/share/man/man1" ];
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ fuse ];
  enableParallelBuilding = true;

  meta = {
    homepage = "https://github.com/ftrvxmtrx/9pfs";
    description = "FUSE-based client of the 9P network filesystem protocol";
    maintainers = [ lib.maintainers.eelco ];
    platforms = lib.platforms.unix;
    license = with lib.licenses; [ lpl-102 bsd2 ];
  };
}
