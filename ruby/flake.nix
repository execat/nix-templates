{
  description = "Developer environment shell for Ruby";

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
