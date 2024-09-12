{
  description = "A Nix-flake-based Nix development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs = { self, nixpkgs }:
    let
      # Helper to provide system-specific attributes
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSupportedSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      devShells = forAllSupportedSystems ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            cachix
            lorri
            niv
            nixfmt-classic
            statix
            vulnix
            haskellPackages.dhall-nix
          ];
        };
      });
    };
}
