{ callPackage, libsForQt5 }:

let
  stableVersion = "2.2.28";
  previewVersion = stableVersion;
  addVersion = args:
    let version = if args.stable then stableVersion else previewVersion;
        branch = if args.stable then "stable" else "preview";
    in args // { inherit version branch; };
  extraArgs = rec {
    mkOverride = attrname: version: sha256:
      self: super: {
        ${attrname} = super.${attrname}.overridePythonAttrs (oldAttrs: {
          inherit version;
          src = oldAttrs.src.override {
            inherit version sha256;
          };
        });
      };
    commonOverrides = [
      (mkOverride "psutil" "5.8.0"
        "sha256-DJzLmat2Al8vC77PNB1GVunBNR24zIoDzNYuMYq0tcY=")
      (mkOverride "jsonschema" "3.2.0"
        "0ykr61yiiizgvm3bzipa3l73rvj49wmrybbfwhvpgk3pscl5pa68")
    ];
  };
  mkGui = args: libsForQt5.callPackage (import ./gui.nix (addVersion args // extraArgs)) { };
  mkServer = args: callPackage (import ./server.nix (addVersion args // extraArgs)) { };
  guiSrcHash = "sha256-5GPGn0ZFlqoKkb5BOzxf2FqwPlu7hZe4ysWDGSROCj0=";
  serverSrcHash = "sha256-7xsgpm4KFeGFbW81/oMUGQSwXWXnBPTHzVVR0/cUe6U=";
in {
  guiStable = mkGui {
    stable = true;
    sha256Hash = guiSrcHash;
  };
  guiPreview = mkGui {
    stable = false;
    sha256Hash = guiSrcHash;
  };

  serverStable = mkServer {
    stable = true;
    sha256Hash = serverSrcHash;
  };
  serverPreview = mkServer {
    stable = false;
    sha256Hash = serverSrcHash;
  };
}
