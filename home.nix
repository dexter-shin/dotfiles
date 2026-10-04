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

  # omp installs itself in .local; Kimi Code in .kimi-code; Grok in .grok.
  home.sessionPath = [ "$HOME/.local/bin" "$HOME/.kimi-code/bin" "$HOME/.grok/bin" ];

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

  home.activation.installKimi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.kimi-code/bin/kimi" ]; then
      run bash -c 'export PATH=${pkgs.curl}/bin:$PATH; curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash' \
        || warnEcho "Kimi Code install failed. Rerun by hand: curl -fsSL https://code.kimi.com/kimi-code/install.sh | bash"
    fi
  '';

  home.activation.installGrok = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.grok/bin/grok" ]; then
      run bash -c 'export PATH=${pkgs.curl}/bin:$PATH SHELL=/bin/sh; curl -fsSL https://x.ai/cli/install.sh | bash' \
        || warnEcho "Grok install failed. Rerun by hand: curl -fsSL https://x.ai/cli/install.sh | bash"
    fi
  '';

  # Global npm CLIs I installed by hand over time: agent CLIs, *-axi tools,
  # Pi extensions and language servers. Same contract as Pi above: install
  # only what is missing, never pin, upgrade through npm itself. Each package
  # installs on its own so one broken publish does not block the rest.
  home.activation.installNpmGlobals = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    let
      packages = [
        # agent CLIs and adapters
        "@openai/codex"
        "@google/gemini-cli"
        "opencode-ai"
        "opencode-anthropic-oauth"
        "oh-my-opencode"
        "oh-my-claude-sisyphus"
        "@agentclientprotocol/claude-agent-acp"
        "@zed-industries/codex-acp"
        "acpx"
        "@nex-ai/nex"
        "claudekit-cli"
        "context-mode"
        "headroom-ai"
        "gnhf"
        "backpass"
        # agent-ergonomic CLI wrappers
        "chrome-devtools-axi"
        "cloudflare-axi"
        "coolify-axi"
        "gh-axi"
        "glab-axi"
        "gws-axi"
        "jev-axi"
        "lavish-axi"
        "mobbin-axi"
        "notion-axi"
        "quota-axi"
        "slack-axi"
        "tasks-axi"
        # Pi extensions installed outside settings.json packages
        "@juicesharp/rpiv-advisor"
        "@juicesharp/rpiv-args"
        "@juicesharp/rpiv-ask-user-question"
        "@juicesharp/rpiv-i18n"
        "@juicesharp/rpiv-pi"
        "@juicesharp/rpiv-todo"
        "@juicesharp/rpiv-web-tools"
        "@plannotator/pi-extension"
        "@tintinweb/pi-subagents"
        "pi-agent-browser-native"
        "pi-btw"
        "pi-caveman"
        "pi-hermes-memory"
        "pi-interactive-shell"
        "pi-mcp-adapter"
        "pi-simplify"
        "pi-studio"
        # documents and media
        "@googleworkspace/cli"
        "@n8n-as-code/transformer"
        "asciicast2gif"
        "designlang"
        "grok-image-cli"
        "k-skill-rhwp"
        "kordoc"
        "md-to-pdf"
        "pdfjs-dist"
        # dev tooling and language servers
        "@ast-grep/cli"
        "bash-language-server"
        "yaml-language-server"
        "typescript"
        "ts-node"
        "ts-morph"
        "gulp-cli"
        "vercel"
      ];
    in
    ''
      for pkg in ${lib.escapeShellArgs packages}; do
        if [ ! -e "/opt/homebrew/lib/node_modules/$pkg" ]; then
          run bash -c 'export PATH=/opt/homebrew/bin:$PATH; npm install -g "$1"' _ "$pkg" \
            || warnEcho "npm install of $pkg failed. Rerun by hand: npm install -g $pkg"
        fi
      done
    ''
  );

  # Python CLIs I installed by hand with uv or pipx. All go through
  # `uv tool install` now, so one tool owns every Python CLI. Same contract as
  # the npm globals: guarded on the CLI's executable in ~/.local/bin (so the
  # existing pipx installs count as present), never pinned, upgraded with
  # `uv tool upgrade --all`.
  home.activation.installUvTools = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    let
      # bin: the executable whose presence means the tool is installed.
      # args: the full `uv tool install` arguments.
      tools = [
        { bin = "chunkhound"; args = [ "chunkhound" ]; }
        { bin = "claude-monitor"; args = [ "claude-monitor" ]; }
        { bin = "graphify"; args = [ "graphifyy" ]; }
        { bin = "it2"; args = [ "it2" ]; }
        { bin = "nlm"; args = [ "notebooklm-mcp-cli" ]; }
        { bin = "ouroboros"; args = [ "ouroboros-ai[tui]" ]; }
        { bin = "serena"; args = [ "serena-agent @ git+https://github.com/oraios/serena" ]; }
        { bin = "trafilatura"; args = [ "trafilatura" ]; }
        { bin = "headroom"; args = [ "headroom-ai[all]" ]; }
        { bin = "hyperresearch"; args = [ "hyperresearch" ]; }
        { bin = "markitdown"; args = [ "markitdown" ]; }
        { bin = "ansible-playbook"; args = [ "ansible" "--with-executables-from" "ansible-core" ]; }
        { bin = "ansible-lint"; args = [ "ansible-lint" ]; }
      ];
      installOne = t: ''
        if [ ! -e "$HOME/.local/bin/${t.bin}" ]; then
          run bash -c 'export PATH=/opt/homebrew/bin:$PATH; uv tool install "$@"' _ ${lib.escapeShellArgs t.args} \
            || warnEcho "uv tool install ${lib.concatStringsSep " " t.args} failed. Rerun it by hand"
        fi
      '';
    in
    lib.concatMapStrings installOne tools
  );

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
