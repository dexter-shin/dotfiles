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

  # omp installs itself in .local; Kimi Code in .kimi-code; Grok in .grok;
  # `go install` in ~/go/bin; krew plugins in ~/.krew/bin, where kubectl
  # finds them as `kubectl <plugin>`.
  home.sessionPath = [ "$HOME/.local/bin" "$HOME/.kimi-code/bin" "$HOME/.grok/bin" "$HOME/go/bin" "$HOME/.krew/bin" ];

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

  # Other CLIs I installed by hand with their vendor's curl installer. Same
  # contract as above: run the documented one-liner only when the binary is
  # missing, never pin, upgrade through each tool's own updater. ~/.local/bin
  # is put on PATH because some installers pick it only when it is there and
  # fall back to /usr/local/bin (sudo) otherwise.
  home.activation.installVendorClis = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    let
      # bin: the file that proves it is installed. cmd: the vendor one-liner.
      tools = [
        { bin = ".local/bin/goose"; cmd = "curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | CONFIGURE=false bash"; }
        # Also links ~/.local/bin/agent, which Grok's installer claims too.
        { bin = ".local/bin/cursor-agent"; cmd = "curl -fsSL https://cursor.com/install | bash"; }
        { bin = ".local/bin/herdr"; cmd = "curl -fsSL https://herdr.dev/install.sh | sh"; }
        { bin = ".local/bin/ak"; cmd = "curl -fsSL https://agentkit.best/install.sh | sh"; }
        { bin = ".local/bin/gjc"; cmd = "curl -fsSL https://raw.githubusercontent.com/Yeachan-Heo/gajae-code/main/scripts/install.sh | sh"; }
        { bin = ".local/bin/plannotator"; cmd = "curl -fsSL https://plannotator.ai/install.sh | bash -s -- --non-interactive"; }
        # Resolves its version through the unauthenticated GitHub API, so it
        # is the one most likely to need a rerun when that rate-limits.
        { bin = ".local/bin/treehouse"; cmd = "curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh"; }
        { bin = ".no-mistakes/bin/no-mistakes"; cmd = "curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh"; }
        # Notion CLI. Pinned to ~/.local/bin; it would otherwise pick the first
        # writable PATH entry, which used to be /usr/local/bin.
        { bin = ".local/bin/ntn"; cmd = "curl -fsSL https://ntn.dev | NTN_INSTALL_DIR=$HOME/.local/bin bash"; }
      ];
      installOne = t: ''
        if [ ! -e "$HOME/${t.bin}" ]; then
          run bash -c 'export PATH=${pkgs.curl}/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin SHELL=/bin/sh; mkdir -p "$HOME/.local/bin"; '${lib.escapeShellArg t.cmd} \
            || warnEcho ${lib.escapeShellArg "${baseNameOf t.bin} install failed. Rerun by hand: ${t.cmd}"}
        fi
      '';
    in
    lib.concatMapStrings installOne tools
  );

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
        # Python language server the editors use; ships its own Node runtime.
        { bin = "basedpyright"; args = [ "basedpyright" ]; }
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

  # Go CLIs I installed by hand with `go install`: the editor tools the Go
  # extension asks for, plus actionlint and songsee. They stay in ~/go/bin,
  # where editors look for them. Same contract as above: install only what is
  # missing, never pin, upgrade by rerunning `go install <path>@latest`.
  home.activation.installGoTools = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    let
      # bin: the executable in ~/go/bin. path: the `go install` package path.
      tools = [
        { bin = "gopls"; path = "golang.org/x/tools/gopls"; }
        { bin = "dlv"; path = "github.com/go-delve/delve/cmd/dlv"; }
        { bin = "staticcheck"; path = "honnef.co/go/tools/cmd/staticcheck"; }
        { bin = "gomodifytags"; path = "github.com/fatih/gomodifytags"; }
        { bin = "gotests"; path = "github.com/cweill/gotests/gotests"; }
        { bin = "impl"; path = "github.com/josharian/impl"; }
        { bin = "goplay"; path = "github.com/haya14busa/goplay/cmd/goplay"; }
        { bin = "go-outline"; path = "github.com/ramya-rao-a/go-outline"; }
        { bin = "actionlint"; path = "github.com/rhysd/actionlint/cmd/actionlint"; }
        { bin = "songsee"; path = "github.com/steipete/songsee/cmd/songsee"; }
      ];
      installOne = t: ''
        if [ ! -e "$HOME/go/bin/${t.bin}" ]; then
          run bash -c 'export PATH=/opt/homebrew/bin:$PATH; go install "$1@latest"' _ ${lib.escapeShellArg t.path} \
            || warnEcho "go install ${t.path}@latest failed. Rerun it by hand"
        fi
      '';
    in
    lib.concatMapStrings installOne tools
  );

  # Rust CLIs I installed by hand with `cargo install`. They go to ~/.local/bin
  # (--root ~/.local) rather than ~/.cargo/bin, because ~/.cargo/bin also holds
  # an old rustup toolchain that must not shadow Homebrew's rust on PATH.
  # Same contract as above; --locked builds against each crate's own lockfile.
  home.activation.installCargoTools = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    let
      # bin: an executable the crate installs. args: the crate source.
      tools = [
        { bin = "cargo-watch"; args = [ "cargo-watch" ]; }
        { bin = "sqlx"; args = [ "sqlx-cli" ]; }
        { bin = "rhwp"; args = [ "--git" "https://github.com/edwardkim/rhwp" "rhwp" ]; }
      ];
      installOne = t: ''
        if [ ! -e "$HOME/.local/bin/${t.bin}" ]; then
          run bash -c 'export PATH=/opt/homebrew/bin:$PATH; cargo install --locked --root "$HOME/.local" "$@"' _ ${lib.escapeShellArgs t.args} \
            || warnEcho "cargo install ${lib.concatStringsSep " " t.args} failed. Rerun it by hand with --locked --root ~/.local"
        fi
      '';
    in
    lib.concatMapStrings installOne tools
  );

  # kubectl plugins I installed by hand with krew (Homebrew's krew formula).
  # ctx and ns are left out: Homebrew's kubectx already ships kubectl-ctx and
  # kubectl-ns. Same contract as above: install only what is missing, never
  # pin, upgrade with `kubectl krew upgrade`.
  home.activation.installKrewPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    let
      plugins = [
        "access-matrix" # kubectl access-matrix: RBAC overview
        "konfig"        # merge and split kubeconfigs
        "neat"          # strip clutter from `kubectl get -o yaml`
        "slice"         # split multi-document YAML into files
      ];
      installOne = p: ''
        if [ ! -e "$HOME/.krew/receipts/${p}.yaml" ]; then
          run bash -c 'export PATH=/opt/homebrew/bin:/usr/bin:$PATH; kubectl-krew install "$1"' _ ${lib.escapeShellArg p} \
            || warnEcho "kubectl krew install ${p} failed. Rerun it by hand"
        fi
      '';
    in
    lib.concatMapStrings installOne plugins
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
