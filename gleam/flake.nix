{
  description = "A Nix-flake-based Gleam development environment";

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
            # use the Elixr/OTP versions defined above; will also install OTP, mix, hex, rebar3
            gleam

            # mix needs it for downloading dependencies
            git

            # probably needed for your Phoenix assets
            nodejs_20
          ]
          ++
          # Linux only
          pkgs.lib.optionals pkgs.stdenv.isLinux (with pkgs; [
            gigalixir
            inotify-tools
            libnotify
          ])
          ++
          # macOS only
          pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs; [
            terminal-notifier
            darwin.apple_sdk.frameworks.CoreFoundation
            darwin.apple_sdk.frameworks.CoreServices
          ]);

          shellHook = ''
            # this allows mix to work on the local directory
            mkdir -p .nix-mix .nix-hex
            export MIX_HOME=$PWD/.nix-mix
            export HEX_HOME=$PWD/.nix-hex

            # make hex from Nixpkgs available
            # `mix local.hex` will install hex into MIX_HOME and should take precedence
            export MIX_PATH="${(pkgs.beam.packagesWith pkgs.beam.interpreters.erlang).hex}/lib/erlang/lib/hex/ebin"
            export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH

            # keep shell history in iex
            export ERL_AFLAGS="-kernel shell_history enabled"
          '';

        };
      });
    };
}
