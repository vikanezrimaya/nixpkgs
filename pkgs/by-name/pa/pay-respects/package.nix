{
  lib,
  fetchFromGitea,
  rustPlatform,
  versionCheckHook,
  openssl,
  pkg-config,
}:

rustPlatform.buildRustPackage rec {
  pname = "pay-respects";
  version = "0.6.2";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "iff";
    repo = "pay-respects";
    rev = "v${version}";
    hash = "sha256-ZfgMu2N2YMGoQXi0FCw0VzjFHv96oQAnH8FkfavKtq0=";
  };

  cargoHash = "sha256-nI15XtMs0/NqLQS319QuJbqZA6ZofWaN6ZtJu/2WsCI=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;

  meta = {
    description = "Terminal command correction, alternative to `thefuck`, written in Rust";
    homepage = "https://codeberg.org/iff/pay-respects";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ sigmasquadron ];
    mainProgram = "pay-respects";
  };
}
