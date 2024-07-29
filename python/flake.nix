{
  description = "Nix Development Flake for your package";

  # Nixpkgs: Branch: Nixos-unstable on 15th July 2024
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/693bc46d169f5af9c992095736e82c3488bf7dbb";

  outputs =
    { self, nixpkgs, flake-utils }:

    flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python312;
        pythonPackages = python.pkgs;
	lib-path = with pkgs; lib.makeLibraryPath [
    	  libffi
    	  openssl
    	  stdenv.cc.cc
	];
      in
      {
        devShells.default = pkgs.mkShell {
          name = "your_package";
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
            export "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${lib-path}"
          '';
        };
      });
}
