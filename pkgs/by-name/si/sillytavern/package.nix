{ lib
, buildNpmPackage
, fetchFromGitHub
, makeWrapper
, pkgs
}:

let
wrapperScript = pkgs.writeShellScriptBin "sillytavern-wrapper" ''
  _BUILDLIBPREFIX="$(dirname "$(readlink -f "$0")")/../lib/sillytavern"
  export NODE_PATH="$_BUILDLIBPREFIX/node_modules"

  ${pkgs.nodejs}/bin/node $_BUILDLIBPREFIX/server.js
'';

in


buildNpmPackage rec {
  pname = "sillytavern";
  version = "1.12.1";
  src = fetchFromGitHub {
    owner = "SillyTavern";
    repo = "SillyTavern";
    rev = "00b44071a611a7e684eb56e12950d4969b5261b3";
    hash = "sha256-OP8HgrI8hAnqHJ9ldyXUAJSmR9NJ+rwC68VLpZaXBMg=";
  };

  npmDepsHash = "sha256-8C/Lp5024XC4SYP3789LotdcgTjrsz3soN1YJ8TWt3k=";

  patches = [ ./lock.patch ./uploads-dataRoot.patch ];

  desktopFile = ./sillytavern.desktop;

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  # Heavily inspired on https://mpr.makedeb.org/pkgbase/sillytavern/git/tree/PKGBUILD

  installPhase = ''
    runHook preInstall

    # Cleanup
    rm -Rf node_modules/onnxruntime-node/bin/napi-v3/{darwin,win32}

    # Creating Directories
    mkdir -p $out/{bin,share/{${pname},doc/${pname},applications,icons/hicolor/72x72/apps},lib/${pname}}

    # doc
    cp LICENSE $out/share/doc/${pname}/license
    cp SECURITY.md $out/share/doc/${pname}/security
    mv .github/readme* $out/share/doc/${pname}/

    # Install
    install -Dm755 ${wrapperScript}/bin/* $out/bin/sillytavern
    mv node_modules $out/lib/${pname}

    # Icon and desktop file
    cp public/img/apple-icon-72x72.png $out/share/icons/hicolor/72x72/apps/${pname}.png
    install -Dm644 ${desktopFile} $out/share/applications/${pname}.desktop
    mv * $out/lib/${pname}

    runHook postInstall
  '';

  meta = with lib; {
    description = "LLM Frontend for Power Users.";
    longDescription = ''
      SillyTavern is a user interface you can install on your computer (and Android phones) that allows you to interact with
      text generation AIs and chat/roleplay with characters you or the community create.
    '';
    downloadPage = "https://github.com/SillyTavern/SillyTavern/releases";
    homepage = "https://docs.sillytavern.app/";
    mainProgram = "sillytavern";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ aikooo7 vikanezrimaya ];
  };
}
