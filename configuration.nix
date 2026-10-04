{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    autoMigrate = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    taps = [
      "argoproj/tap"
      "asmvik/formulae"
      "buildpacks/tap"
      "cartr/qt4"
      "cloudflare/cloudflare"
      "codingmoh/open-codex"
      "coollabsio/coolify-cli"
      "common-fate/granted"
      "derailed/k9s"
      "derailed/popeye"
      "drolosoft/tap"
      "felixkratz/formulae"
      "gabrie30/utils"
      "gjbae1212/gossm"
      "gofireflyio/aiac"
      "goodwithtech/r"
      "heroku/brew"
      "infograb/j2lab"
      "jesseduffield/lazygit"
      "johanhaleby/kubetail"
      "kubeshark/kubeshark"
      "kubeshop/botkube"
      "kubeshop/fuse-releases"
      "manaflow-ai/cmux"
      "mattt/tap"
      "messense/macos-cross-toolchains"
      "minamijoyo/hcledit"
      "mongodb/brew"
      "navercloudplatform/tap"
      "netbirdio/tap"
      "ngrok/ngrok"
      "ramiawar/dataline"
      "robscott/tap"
      "robusta-dev/holmesgpt"
      "silver-flight-group/tap"
      "stablyai/orca"
      "supabase/tap"
      "tailwarden/komiser"
      "tinyhumansai/core"
      "tokiwong/tap"
      "txn2/tap"
      "vossenwout/crev"
      "warrensbox/tap"
      "withgraphite/tap"
    ];
    brews = [
      "age"
      "argocd-autopilot"
      "argoproj/tap/kubectl-argo-rollouts"
      "asdf"
      "aspcud"
      "ata"
      "autoenv"
      "aws-iam-authenticator"
      "awscli"
      "azure-cli"
      "bat"
      "beads"
      "bitwarden-cli"
      "brainfuck"
      "btop"
      "bun"
      "cask"
      "cava"
      "cheat"
      "checkov"
      "claude-squad"
      "cloudflared"
      "cmake"
      "colima"
      "coollabsio/coolify-cli/coolify-cli"
      "conftest"
      "curl"
      "d2"
      "direnv"
      "dive"
      "dnsmasq"
      "docker-compose"
      "docker-credential-helper"
      "docker-credential-helper-ecr"
      "docutils"
      "dpkg"
      "duckdb"
      "dust"
      "eksctl"
      "erlang"
      "exiftool"
      "eza"
      "fabric-ai"
      "felixkratz/formulae/sketchybar"
      "ffmpeg"
      "gh"
      "ghostscript"
      "gifsicle"
      "git"
      "git-lfs"
      "gitlab-runner"
      "gitleaks"
      "gitmoji"
      "glab"
      "glow"
      "go"
      "go-task"
      "goodwithtech/r/dockertags"
      "gradle"
      "graphicsmagick"
      "graphviz"
      "groovy"
      "heimdal"
      "helm"
      "herdr"
      "htop"
      "hugo"
      "imagemagick"
      "infracost"
      "johanhaleby/kubetail/kubetail"
      "jsonnet"
      "k3d"
      "k6"
      "k9s"
      "krew"
      "kube-ps1"
      "kubeconform"
      "kubectx"
      "kubeseal"
      "kubeshop/botkube/botkube"
      "kubeshop/fuse-releases/fuse"
      "kubie"
      "kustomize"
      "libass"
      "libiconv"
      "libpq"
      "libraw"
      "llama.cpp"
      "llmfit"
      "lsd"
      "lynx"
      "mailsy"
      "marp-cli"
      "mas"
      "maven"
      "minikube"
      "mise"
      "mole"
      "navercloudplatform/tap/ncp-iam-authenticator"
      "netbirdio/tap/netbird"
      "nixpacks"
      "node"
      "ollama"
      "openjdk@17"
      "opentofu"
      "optipng"
      "pandoc"
      "pass"
      "pipes-sh"
      "pipx"
      "pngpaste"
      "pnpm"
      "podman"
      "poppler"
      "postgresql@14"
      "pre-commit"
      "procs"
      "putty"
      "py3cairo"
      "python@3.11"
      "python@3.9"
      "qemu"
      "ramiawar/dataline/dataline"
      "rbenv"
      "re2"
      "repo"
      "robusta-dev/holmesgpt/holmesgpt"
      "rtk"
      "ruby"
      "runit"
      "rust"
      "rust-analyzer"
      "scipy"
      "serve"
      "sevenzip"
      "shellcheck"
      "siege"
      "skillshare"
      "sox"
      "speedtest-cli"
      "sshpass"
      "stern"
      "subversion"
      "swaks"
      "switchaudio-osx"
      "tailscale"
      "telnet"
      "terraform"
      "terraform-docs"
      "terrascan"
      "tflint"
      "tfsec"
      "tfupdate"
      "thefuck"
      "warrensbox/tap/tgswitch"
      "timewarrior"
      "tmux"
      "trivy"
      "tty-clock"
      "util-linux"
      "uv"
      "vault"
      "virtctl"
      "virtualenv"
      "vossenwout/crev/crev"
      "watch"
      "wget"
      "wireguard-tools"
      "withgraphite/tap/graphite"
      "yamllint"
      "yq"
      "yt-dlp"
      "zoxide"
      "zrok"
    ];
    casks = [
      "1password-cli"
      "5ire"
      "android-platform-tools"
      "applite"
      "aws-vault-binary"
      "background-music"
      "claude-code"
      "devtoys"
      "discord"
      "font-azonix"
      "font-d2coding-nerd-font"
      "font-fira-code"
      "font-hack-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-space-grotesk"
      "freelens"
      "gcloud-cli"
      "ghostty"
      "hop"
      "kitty"
      "libreoffice"
      "maccy"
      "macfuse"
      "ngrok"
      "opencode-desktop"
      "orbstack"
      "orca"
      "raycast"
      "sf-symbols"
      "slack-cli"
      "temurin"
      "tfswitch"
      "visual-studio-code"
      "warp"
      "wezterm"
    ];
    # Mac App Store apps, keyed by display name. IDs come from `mas list`.
    # cleanup = "zap" never removes these, so drop an app by uninstalling it too.
    masApps = {
      "Amphetamine" = 937984704;
      "Canva" = 897446215;
      "Citrix Secure Access" = 1338991513;
      "Desk Remote Control" = 1509037746;
      "GarageBand" = 682658836;
      "Hancom Office HWP Viewer" = 416746898;
      "iMovie" = 408981434;
      "KakaoTalk" = 869223134;
      "Keka" = 470158793;
      "Keynote" = 361285480;
      "LINE" = 539883307;
      "Microsoft Remote Desktop" = 1295203466;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "Perplexity" = 6714467650;
      "ScreenBrush" = 1233965871;
      "Session" = 1521432881;
      "SuperCut" = 6784451245;
      "The Unarchiver" = 425424353;
      "Turbo VPN" = 1493508424;
      "WhatsApp" = 310633997;
      "WireGuard" = 1451685025;
      "Xcode" = 497799835;
    };
  };
}
