{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  bashNonInteractive,
}:
stdenvNoCC.mkDerivation rec {
  pname = "nodejs-prebuilt";
  version = "26.12.1";

  src = fetchurl {
    url = "https://nodejs.org/dist/v${version}/node-v${version}-linux-x64.tar.xz";
    hash = "sha256-YXCy1HThxib0PP863BGN+f47VzJYpPw9hQyNvGsHm70=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    stdenv.cc.cc.lib
    bashNonInteractive
  ];
  # Sorting ELF headers corrupts this upstream executable during RPATH rewriting.
  patchelfFlags = [ "--no-sort" ];
  strictDeps = true;
  dontConfigure = true;
  dontBuild = true;
  # Preserve upstream symbols used by DSH's native runtime introspection.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -a . "$out/"
    runHook postInstall
  '';

  postFixup = ''
    # npm and npx must use this Node even when another version is on PATH.
    HOST_PATH="$out/bin:$HOST_PATH" patchShebangs --host "$out/lib/node_modules/npm"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$TMPDIR/test-home"
    mkdir -p "$HOME"
    "$out/bin/node" --version
    "$out/bin/node" -e 'require("node:assert/strict").equal(process.version, "v${version}")'
    "$out/bin/npm" --version
    "$out/bin/npx" --version
    runHook postInstallCheck
  '';

  meta = {
    description = "Official prebuilt Node.js with bundled npm and npx";
    homepage = "https://nodejs.org/";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "node";
  };
}
