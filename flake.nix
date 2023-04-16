{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        formatter = pkgs.nixpkgs-fmt;
        rustVersion = pkgs.rust-bin.stable.latest.default;
        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustVersion;
          rustc = rustVersion;
        };
        rustBuild = rustPlatform.buildRustPackage {
          pname =
            "nix-rust";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ ];
          cargoLock.lockFile = ./Cargo.lock;
        };
        dockerImage = pkgs.dockerTools.buildImage {
          name = "nix-rust";
          tag = "latest";
          created = "now";
          config = { Cmd = [ "${rustBuild}/bin/nix-rust" ]; };
        };
        devShell = pkgs.mkShellNoCC {
          name = "nix-rust";
          shellHook = "echo Welcome to your Nix-powered development environment!";
          buildInputs =
            [ (rustVersion.override { extensions = [ "rust-src" ]; }) ];
          packages = with pkgs; [
            aws-vault
            awscli
            docker-compose
            kubectl
            localstack
            minikube
            overmind
            terraform
            terragrunt
          ];
        };
      in
      {
        formatter = formatter;
        packages = {
          default = rustBuild;
          docker = dockerImage;
        };
        devShells = {
          default = devShell;
        };
        apps = {
          default = {
            program = "${rustBuild}/bin/nix-rust";
            type = "app";
          };
        };
      }
    );
}
