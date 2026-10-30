{
  description = "dotfiles";

  inputs = {
    # Use `github:NixOS/nixpkgs/nixpkgs-26.05-darwin` to use Nixpkgs 26.05.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Use `github:nix-darwin/nix-darwin/nix-darwin-26.05` to use Nixpkgs 26.05.
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # nix-homebrew pins Homebrew 6.0.1, but the Homebrew JSON API always serves
    # cask definitions written against the current release. The pinned client
    # cannot parse the newer cask DSL (`command_wrapper`, `discontinued`) and
    # every `brew bundle` fails, so pin Homebrew forward ourselves.
    # Fetched over git rather than `github:` so it does not burn the
    # unauthenticated GitHub API rate limit on every lock update.
    brew-src.url = "git+https://github.com/Homebrew/brew.git?ref=refs/tags/7.0.11&shallow=1";
    brew-src.flake = false;
    nix-homebrew.inputs.brew-src.follows = "brew-src";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, nixpkgs, ... }:
    let
      # The one username line to change if this isn't your machine.
      # bootstrap.sh offers to rewrite this for you if your macOS username differs.
      user = "dex";
    in
    {
      darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user; };
        modules = [
          ./configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Adopting an already-populated machine: move a pre-existing file
            # aside as <name>.bak instead of aborting the whole activation.
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = { inherit user; };
            home-manager.users.${user} = import ./home.nix;
          }
        ];
      };
    };
}
