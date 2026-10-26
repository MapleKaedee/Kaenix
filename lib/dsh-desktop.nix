{
  lib,
  callPackage,
  fetchFromGitHub,
  rustPlatform,
  cargo-tauri,
  pkg-config,
  wrapGAppsHook3,
  gtk3,
  webkitgtk_4_1,
  glib-networking,
  libayatana-appindicator,
  librsvg,
  xdotool,
  openssl,
  cacert,
  pnpm_10,
  python3,
  writeShellScript,
}:
let
  node = callPackage ./nodejs-prebuilt.nix { };
  pnpm = pnpm_10.override { nodejs-slim = node; };
  helper = writeShellScript "dsh-desktop-runtime" ''
    exec ${python3}/bin/python3 ${../scripts/dsh-desktop-runtime.py} \
      --node ${node}/bin/node --npm ${node}/bin/npm \
      --pnpm-bin ${pnpm}/bin "$@"
  '';
  # Opaque layout is intentional: upstream must not infer an npm global prefix.
  backend = writeShellScript "dsh-desktop-backend" ''
    exec ${helper} --backend-launcher "$0" backend "$@"
  '';
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dsh-desktop";
  version = "0.1.29";

  src = fetchFromGitHub {
    owner = "MochiNek0";
    repo = "dsh-desktop";
    rev = "e9dc7283846f31ec9f3215525c4e9deeacaf0f9b";
    hash = "sha256-peCEaSOvwWrbqlFe1wLQUFZSu9QIkzPwrnvBlGYt6QU=";
  };
  sourceRoot = "${finalAttrs.src.name}/src-tauri";
  cargoHash = "sha256-ChzWMnVzMkRYXWQ8E/ohCKTq1WMhdfkZ8919Z9LIJCw=";

  postPatch = ''
    patch -p2 < ${../config/dsh-desktop/managed-runtime.patch}
    # libappindicator-sys uses dlopen: a build input alone cannot locate it.
    substituteInPlace "$cargoDepsCopy"/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail 'libayatana-appindicator3.so.1' \
        '${libayatana-appindicator}/lib/libayatana-appindicator3.so.1'
    cp ${../config/dsh-desktop/kaenix.rs} src/kaenix.rs
    substituteInPlace src/kaenix.rs \
      --replace-fail '@kaenixHelper@' '${helper}' \
      --replace-fail '@kaenixBackend@' '${backend}'
    substituteInPlace src/dsh.rs \
      --replace-fail '@kaenixResources@' "$out/share/dsh-desktop/resources"
    substituteInPlace tauri.conf.json \
      --replace-fail '"beforeBuildCommand": "npm run bundle:runtime"' '"beforeBuildCommand": ""' \
      --replace-fail '"beforeDevCommand": "npm run bundle:runtime"' '"beforeDevCommand": ""' \
      --replace-fail '"createUpdaterArtifacts": true' '"createUpdaterArtifacts": false'
    # The tracked frontend is static; staging needs only Node built-ins.
    ${node}/bin/node ../scripts/bundle-runtime.mjs
    # Sibling plugin/ stays read-only after unpacking sourceRoot=src-tauri.
    # Node preserves those modes; Tauri's test build recopies the resources.
    chmod -R u+w resources
    # No runtime installer is shipped by this Nix-managed variant.
    rm resources/install-deps.sh resources/install-deps.ps1
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    pkg-config
    wrapGAppsHook3
  ];
  buildInputs = [
    gtk3
    webkitgtk_4_1
    glib-networking
    libayatana-appindicator
    librsvg
    xdotool
    openssl
  ];

  # reqwest initializes its native-root TLS verifier even for loopback HTTP.
  # Nix's build sandbox has no system trust store; keep verification enabled.
  preCheck = ''
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
  '';

  postInstall = ''
    mkdir -p "$out/share/dsh-desktop"
    cp -R resources "$out/share/dsh-desktop/resources"
    install -m755 ${writeShellScript "dsh-desktop-setup" ''
      exec ${helper} --backend-launcher ${backend} setup "$@"
    ''} "$out/bin/dsh-desktop-setup"
  '';

  passthru = {
    inherit
      node
      pnpm
      helper
      backend
      ;
  };
  meta = {
    description = "Unofficial DSH desktop client with mandatory private Kaenix runtime";
    homepage = "https://github.com/MochiNek0/dsh-desktop";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "dsh-desktop";
  };
})
