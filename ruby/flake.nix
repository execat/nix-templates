{
  description = "Developer environment shell for Ruby";

  inputs = {
    # Nixpkgs: branch: nixos-unstable
    # Updated: 15th July 2024
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "693bc46d169f5af9c992095736e82c3488bf7dbb";
    };
  };

  outputs = { self, nixpkgs }:
    let
      # Helper to provide system-specific attributes
      forAllSupportedSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in

    {
      devShells = forAllSupportedSystems ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            git
            gnumake
            libyaml
            postgresql
            ruby_3_3
            bundler

            entr
            fswatch
            watchman

            rubyPackages_3_3.activesupport
            rubyPackages_3_3.awesome_print
            rubyPackages_3_3.irb
            rubyPackages_3_3.pry
            rubyPackages_3_3.pry-byebug
            rubyPackages_3_3.rake
            rubyPackages_3_3.rest-client
            rubyPackages_3_3.rspec
            rubyPackages_3_3.rubocop
            rubyPackages_3_3.ruby-lsp
            rubyPackages_3_3.sorbet-runtime
          ];
        };
      });
    };
}
