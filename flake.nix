# See more usages of nocargo at https://github.com/oxalica/nocargo#readme
{
  description = "Rust package penrose-wm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nocargo = {
      url = "github:oxalica/nocargo";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.registry-crates-io.follows = "registry-crates-io";
    };
    # Optionally, you can override crates.io index to get cutting-edge packages.
    registry-crates-io = { url = "github:rust-lang/crates.io-index"; flake = false; };
  };

  outputs = { nixpkgs, flake-utils, rust-overlay, nocargo, ... }@inputs:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let

        # for development
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };

        # for building
        ws = nocargo.lib.${system}.mkRustPackageOrWorkspace {
          src = ./.;

          buildCrateOverrides = with nixpkgs.legacyPackages.${system}; {
            # Use package name to reference local crates.
            "penrose-wm" = old: {
              nativeBuildInputs = [
                glib.dev
                cairo.dev
                pango.dev
                harfbuzz.dev
                pkg-config
                python3
                xorg.libxcb.dev
                xorg.libXrandr.dev
                xorg.libXrender.dev
                xorg.xmodmap
              ];
            };
          };
        };
      in
      rec {
        packages = {
          default = packages.penrose-wm;
          penrose-wm = ws.release.penrose-wm.bin;
          penrose-wm-dev = ws.dev.penrose-wm.bin;
        };

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            rust-bin.stable.latest.default

            glib.dev
            cairo.dev
            pango.dev
            harfbuzz.dev
            pkg-config
            python3
            xorg.libxcb.dev
            xorg.libXrandr.dev
            xorg.libXrender.dev
            xorg.xmodmap

          ];
        };
      });
}

