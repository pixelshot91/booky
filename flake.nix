{
  description = "A devShell example";

  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        flutter_rust_bridge_codegen = import ./nix/flutter_rust_bridge_codegen.nix {
                  inherit pkgs;
                };
      in
      {
        devShells.default = with pkgs; mkShell {
          buildInputs = [
            openssl
            pkg-config
            eza
            which
            strace
            fd
            flutter

            # For super_native_extension
            gtk3
            # It would be cleaner to take the toolchain version directly from the toolchain.toml file, but the option describe in oxalica/rust-overlay README does not work
            # rust-bin.fromRustupToolchainFile ./rust-toolchain

            rust-bin.stable."1.79.0".default

            flutter_rust_bridge_codegen

            # Personal preference
            # TODO: move somewhere else
            fish
          ];

          shellHook = ''
            # Prevent cargo 'install --list' to escape Nix isolation
            # export CARGO_INSTALL_ROOT=/home/julien/Perso/LeBonCoin/chain_automatisation/booky/.cargo
            alias ls=eza
            alias find=fd
          '';
        };
      }
    );
}

