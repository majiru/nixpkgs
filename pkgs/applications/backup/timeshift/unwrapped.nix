{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, gettext
, pkg-config
, vala
, which
, gtk3
, json-glib
, libgee
, util-linux
, vte
, xapp
}:

stdenv.mkDerivation rec {
  pname = "timeshift";
  version = "22.11.2";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "timeshift";
    rev = version;
    sha256 = "yZNERRoNZ1K7BRiAu7sqVQyhghsS/AeZSODMVSm46oY=";
  };

  patches = [
    ./timeshift-launcher.patch

    # Use /usr/bin/env bash for shebang
    # On nixos-unstable this is fixed via 23.07.1 bump
    # https://github.com/linuxmint/timeshift/pull/209
    (fetchpatch {
      url = "https://github.com/linuxmint/timeshift/commit/bb8b2a2020be8c9919310de22f547b46177ed327.patch";
      hash = "sha256-DyGMxMiUfmm5FCEQD9L7LLj2LxxNVRt+aTNFl4jrH4Y=";
    })
  ];

  postPatch = ''
    while IFS="" read -r -d $'\0' FILE; do
      substituteInPlace "$FILE" \
        --replace "/sbin/blkid" "${util-linux}/bin/blkid"
    done < <(find ./src -mindepth 1 -name "*.vala" -type f -print0)
    substituteInPlace ./src/Utility/IconManager.vala \
      --replace "/usr/share" "$out/share"
    substituteInPlace ./src/Core/Main.vala \
      --replace "/etc/timeshift/default.json" "$out/etc/timeshift/default.json" \
      --replace "file_copy(app_conf_path_default, app_conf_path);" "if (!dir_exists(file_parent(app_conf_path))){dir_create(file_parent(app_conf_path));};file_copy(app_conf_path_default, app_conf_path);"
  '';

  nativeBuildInputs = [
    gettext
    pkg-config
    vala
    which
  ];

  buildInputs = [
    gtk3
    json-glib
    libgee
    vte
    xapp
  ];

  preBuild = ''
    makeFlagsArray+=( \
      "-C" "src" \
      "prefix=$out" \
      "sysconfdir=$out/etc" \
    )
  '';

  meta = with lib; {
    description = "A system restore tool for Linux";
    longDescription = ''
      TimeShift creates filesystem snapshots using rsync+hardlinks or BTRFS snapshots.
      Snapshots can be restored using TimeShift installed on the system or from Live CD or USB.
    '';
    homepage = "https://github.com/linuxmint/timeshift";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ShamrockLee bobby285271 ];
  };
}
