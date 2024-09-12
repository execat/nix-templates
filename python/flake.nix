{
  description = "Developer environment shell for Python";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      # Helper to provide system-specific attributes
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSupportedSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f rec {
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python313;
        pythonPackages = python.pkgs;
        libPaths = with pkgs; lib.makeLibraryPath [
          libffi
          openssl
          stdenv.cc.cc
        ];
      });
    in
    {
      devShells = forAllSupportedSystems ({ pkgs, python, pythonPackages, libPaths }: {
        default = pkgs.mkShell {
          name = "Python Shell";
          nativeBuildInputs = [ pkgs.bashInteractive ];
          buildInputs = with pythonPackages; [
            pkgs.poetry
            setuptools
            pip
            wheel
            venvShellHook
          ];
          venvDir = ".venv";
          src = null;
          postVenv = ''
            unset SOURCE_DATE_EPOCH
          '';
          postShellHook = ''
            unset SOURCE_DATE_EPOCH
            unset LD_PRELOAD

            PYTHONPATH=$PWD/$venvDir/${python.sitePackages}:$PYTHONPATH
            export "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${libPaths}"
          '';
        };
      });
    };
}
