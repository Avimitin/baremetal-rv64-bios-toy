{
  description = "Generic devshell setup";

  inputs = {
    # The nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Utility functions
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      pkgsForSys = system: import nixpkgs { inherit system; };
      perSystem = (system:
        let
          pkgs = pkgsForSys system;
        in
        {
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              qemu
              llvmPackages_16.clang
              llvmPackages_16.bintools
            ];
          };

          packages.hello = pkgs.stdenv.mkDerivation {
            name = "hello-baremetal";
            buildInputs = with pkgs.llvmPackages_16; [
              clang
              bintools
            ];
            src = ./src;
            buildPhase = ''
              clang --target=riscv64 -mabi=lp64 -march=rv64i -c hello.s -o hello.o
              ld.lld --script hello.ld --no-dynamic-linker -melf64lriscv -static -nostdlib -s -o hello hello.o
            '';
            installPhase = ''
              mkdir -p $out/bin
              mv hello $out/bin
            '';
          };

          formatter = pkgs.nixpkgs-fmt;
        });
    in
    {
      # Other system-independent attr
    } //

    flake-utils.lib.eachDefaultSystem perSystem;
}
