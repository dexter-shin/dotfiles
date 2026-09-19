{ config, lib, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  # omp installs itself here, and nothing else on PATH provides it.
  home.sessionPath = [ "$HOME/.local/bin" ];

  # Neither agent CLI is in Nixpkgs or Homebrew. Pi is published on npm only;
  # omp ships a prebuilt binary from its own installer and its npm package
  # declares a bun engine, so npm is not an option for it either. Both steps
  # run the vendor's own documented command, once, guarded on the binary
  # already being there - so later switches cost nothing and no version is
  # pinned here. Upgrade each through itself.
  #
  # Activation runs under `set -eu -o pipefail` with a Nix-only PATH, so each
  # step brings the tools it needs and swallows its own failure. A flaky
  # network must not abort the switch and leave a half-applied generation:
  # /run/current-system is only repointed after every activation step.
  home.activation.installPi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e /opt/homebrew/bin/pi ]; then
      run bash -c 'export PATH=/opt/homebrew/bin:$PATH; npm install -g --ignore-scripts @earendil-works/pi-coding-agent' \
        || warnEcho "Pi install failed. Rerun by hand: npm install -g --ignore-scripts @earendil-works/pi-coding-agent"
    fi
  '';

  # The installer resolves its version through the unauthenticated GitHub API,
  # which rate-limits, so this is the likelier of the two to need a retry.
  home.activation.installOmp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.local/bin/omp" ]; then
      run bash -c 'export PATH=${pkgs.curl}/bin:$PATH; curl -fsSL https://omp.sh/install | sh' \
        || warnEcho "omp install failed. Rerun by hand: curl -fsSL https://omp.sh/install | sh"
    fi
  '';

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      vi = "nvim";
      vim = "nvim";
      nvim = "nvim";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # Keep Pi's credential and runtime state local by linking only authored files and directories.
  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
