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
      ApplePressAndHoldEnabled = false;    # key repeat instead of the accent popup
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;  # no "." on double space
      "com.apple.trackpad.scaling" = 3.0;  # fastest trackpad tracking
    };
    dock.autohide = true;
    dock.tilesize = 16;
    dock.mru-spaces = false;               # keep Spaces in a fixed order
    dock.minimize-to-application = true;
    dock.wvous-bl-corner = 2;              # hot corner: Mission Control
    dock.wvous-br-corner = 11;             # hot corner: Launchpad
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    finder.AppleShowAllFiles = true;       # show hidden files
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;
    finder._FXSortFoldersFirst = true;
    finder.FXDefaultSearchScope = "SCcf";  # search the current folder
    finder.NewWindowTarget = "Home";
    trackpad.Clicking = true;              # tap to click
    screencapture.show-thumbnail = false;  # save screenshots without the preview delay
    # Turn off macOS edge-drag window tiling.
    WindowManager.EnableTilingByEdgeDrag = false;
    WindowManager.EnableTopTilingByEdgeDrag = false;
    WindowManager.EnableTiledWindowMargins = false;
    CustomUserPreferences."com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;     # no .DS_Store on network shares
      DSDontWriteUSBStores = true;         # or on USB drives
    };
    # English (ABC) + Korean 2-Set input, with the fn key starting dictation.
    CustomUserPreferences."com.apple.HIToolbox" = {
      AppleEnabledInputSources = [
        { InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 252; "KeyboardLayout Name" = "ABC"; }
        { "Bundle ID" = "com.apple.inputmethod.Korean"; "Input Mode" = "com.apple.inputmethod.Korean.2SetKorean"; InputSourceKind = "Input Mode"; }
        { "Bundle ID" = "com.apple.inputmethod.Korean"; InputSourceKind = "Keyboard Input Method"; }
        { "Bundle ID" = "com.apple.CharacterPaletteIM"; InputSourceKind = "Non Keyboard Input Method"; }
        { "Bundle ID" = "com.apple.PressAndHold"; InputSourceKind = "Non Keyboard Input Method"; }
        { "Bundle ID" = "com.apple.inputmethod.ironwood"; InputSourceKind = "Non Keyboard Input Method"; }
      ];
      AppleFnUsageType = 3;
      AppleGlobalTextInputProperties.TextInputGlobalPropertyPerContextInput = true;
    };
    # Keyboard shortcuts. `defaults write` replaces the whole dictionary, so
    # this is the full live set. The hand-changed ones:
    # - 60/61: Cmd+Space and F18 switch input source. Karabiner maps Caps Lock
    #   to F18, so Caps Lock toggles English/Korean.
    # - 64/65: Spotlight shortcuts off, since Cmd+Space is the input switch.
    # - 28-31, 184: built-in screenshot shortcuts off.
    CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys =
      let
        key = enabled: parameters: { inherit enabled; value = { type = "standard"; inherit parameters; }; };
        on = key true;
        off = key false;
      in {
        "7" = on [ 65535 120 8650752 ];
        "8" = on [ 65535 99 8650752 ];
        "9" = on [ 65535 118 8650752 ];
        "10" = on [ 65535 96 8650752 ];
        "11" = on [ 65535 97 8650752 ];
        "12" = on [ 65535 122 8650752 ];
        "13" = on [ 65535 98 8650752 ];
        "15" = { enabled = false; };
        "16" = { enabled = false; };
        "17" = { enabled = false; };
        "18" = { enabled = false; };
        "19" = { enabled = false; };
        "20" = { enabled = false; };
        "21" = off [ 56 28 1835008 ];
        "22" = { enabled = false; };
        "23" = { enabled = false; };
        "24" = { enabled = false; };
        "25" = off [ 46 47 1835008 ];
        "26" = off [ 44 43 1835008 ];
        "27" = on [ 96 50 1048576 ];
        "28" = off [ 51 20 1179648 ];
        "29" = off [ 51 20 1441792 ];
        "30" = off [ 52 21 1179648 ];
        "31" = off [ 52 21 1441792 ];
        "32" = on [ 65535 126 8650752 ];
        "33" = on [ 65535 125 8650752 ];
        "34" = on [ 65535 126 8781824 ];
        "35" = on [ 65535 125 8781824 ];
        "36" = on [ 65535 103 8388608 ];
        "37" = on [ 65535 103 8519680 ];
        "52" = on [ 100 2 1572864 ];
        "57" = on [ 65535 100 8650752 ];
        "59" = on [ 65535 96 9437184 ];
        "60" = on [ 32 49 1048576 ];
        "61" = on [ 65535 79 8388608 ];
        "64" = off [ 65535 49 262144 ];
        "65" = off [ 65535 49 786432 ];
        "79" = on [ 65535 123 8650752 ];
        "80" = on [ 65535 123 8781824 ];
        "81" = on [ 65535 124 8650752 ];
        "82" = on [ 65535 124 8781824 ];
        "98" = on [ 47 44 1179648 ];
        "118" = off [ 65535 18 262144 ];
        "119" = off [ 65535 19 262144 ];
        "120" = off [ 65535 20 262144 ];
        "160" = off [ 65535 65535 0 ];
        "162" = on [ 65535 96 9961472 ];
        "163" = off [ 65535 65535 0 ];
        "164" = { enabled = true; value = { type = "modifier"; parameters = [ 8388608 4286578687 ]; }; };
        "175" = on [ 65535 65535 0 ];
        "176" = { enabled = false; value.type = "SAE1.0"; };
        "179" = { enabled = false; };
        "184" = off [ 53 23 1179648 ];
        "190" = on [ 113 12 8388608 ];
      };
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
    # Write third-party tap formulae and casks as "user/tap/name". Homebrew only
    # trusts fully qualified entries, and brew bundle refuses untrusted ones.
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
      "asmvik/formulae/skhd"
      "asmvik/formulae/yabai"
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
      "buildpacks/tap/pack"
      "bun"
      "cask"
      "cava"
      "cheat"
      "checkov"
      "claude-squad"
      "cloudflared"
      "cmake"
      "colima"
      "common-fate/granted/granted"
      "coollabsio/coolify-cli/coolify-cli"
      "conftest"
      "coreutils"
      "curl"
      "d2"
      "derailed/popeye/popeye"
      "direnv"
      "dive"
      "dnsmasq"
      "docker-compose"
      "docker-credential-helper"
      "docker-credential-helper-ecr"
      "docutils"
      "dpkg"
      "drolosoft/tap/cmux-resurrect"
      "duckdb"
      "dust"
      "eksctl"
      "erlang"
      "exiftool"
      "eza"
      "fabric-ai"
      "felixkratz/formulae/sketchybar"
      "ffmpeg"
      "gabrie30/utils/ghorg"
      "gh"
      "ghostscript"
      "gifsicle"
      "git"
      "git-lfs"
      "gitlab-runner"
      "gitleaks"
      "gitmoji"
      "gjbae1212/gossm/gossm"
      "glab"
      "glow"
      "gnupg"
      "go"
      "go-task"
      "gofireflyio/aiac/aiac"
      "goodwithtech/r/dockertags"
      "gradle"
      "graphicsmagick"
      "graphviz"
      "groovy"
      "heimdal"
      "helm"
      "herdr"
      "heroku/brew/heroku"
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
      "kubernetes-cli"
      "kubeseal"
      "kubeshark/kubeshark/kubeshark"
      "kubeshop/botkube/botkube"
      "kubeshop/fuse-releases/fuse"
      "kubie"
      "kustomize"
      "libass"
      "libiconv"
      "libpq"
      "libraw"
      "lima"
      "llama.cpp"
      "llmfit"
      "lsd"
      "lynx"
      "mailsy"
      "marp-cli"
      "mas"
      "mattt/tap/emcee"
      "maven"
      "messense/macos-cross-toolchains/aarch64-unknown-linux-gnu"
      "messense/macos-cross-toolchains/x86_64-unknown-linux-gnu"
      "minamijoyo/hcledit/hcledit"
      "minikube"
      "mise"
      "mole"
      "mongodb/brew/mongodb-community"
      # Trusting a formula does not trust its same-tap dependencies, so
      # mongodb-community needs this one declared to install on a fresh machine.
      "mongodb/brew/mongodb-database-tools"
      "navercloudplatform/tap/ncp-iam-authenticator"
      "netbirdio/tap/netbird"
      "nixpacks"
      "node"
      # Runs `ollama serve` as a login LaunchAgent, as `brew services start` did.
      {
        name = "ollama";
        start_service = true;
      }
      "openjdk"
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
      "qrencode"
      "ramiawar/dataline/dataline"
      "rbenv"
      "re2"
      "repo"
      "robscott/tap/kube-capacity"
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
      "silver-flight-group/tap/kakaocli"
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
      "tesseract"
      "tflint"
      "tfsec"
      "tfupdate"
      "thefuck"
      "tokiwong/tap/helm-switcher"
      "txn2/tap/kubefwd"
      "warrensbox/tap/tgswitch"
      "timewarrior"
      "tmux"
      "tpm"
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
    # extraFlags "--force" makes brew bundle install casks with --force instead of
    # --adopt, so a hand-installed app in /Applications or a font in ~/Library/Fonts
    # is replaced by the cask's current version, even when versions or bytes differ.
    # App data in ~/Library is untouched. pkg-based casks (zoom, microsoft-*,
    # karabiner-elements, ...) run their installer again and ask for sudo.
    casks = [
      "1password"
      "1password-cli"
      "5ire"
      "android-platform-tools"
      "antigravity"
      "antigravity-ide"
      "applite"
      "aside"
      "aws-vault-binary"
      "background-music"
      "betterdisplay"
      "blackhole-2ch"
      "block-buzz"
      "block-goose"
      "chatgpt"
      "claude"
      "claude-code"
      "cleanshot"
      "conductor"
      "cursor"
      "dbeaver-community"
      "devtoys"
      "discord"
      "drawio"
      "dropbox"
      "elgato-capture-device-utility"
      "elgato-control-center"
      "elgato-stream-deck"
      "figma"
      "font-azonix"
      "font-black-han-sans"
      "font-d2coding-nerd-font"
      "font-fira-code"
      "font-gmarket-sans"
      "font-hack-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-meslo-for-powerlevel10k"
      "font-nanum-square"
      "font-nanum-square-neo"
      "font-nanum-square-round"
      "font-pretendard"
      "font-sf-mono"
      "font-sketchybar-app-font"
      "font-space-grotesk"
      "freelens"
      "gcloud-cli"
      "ghostty"
      "google-chrome"
      "google-drive"
      "grok-bot"
      "hop"
      "hyperwhisper"
      "imaging-edge"
      "imazing"
      "insta360-link-controller"
      "insta360-studio"
      "intellij-idea"
      "iterm2"
      "itermai"
      "karabiner-elements"
      "kimi"
      "kitty"
      "libreoffice"
      "linear"
      "logi-options+"
      "loom"
      "maccy"
      "macfuse"
      "mattermost"
      "microsoft-excel"
      "microsoft-powerpoint"
      "microsoft-word"
      "monologue"
      "ngrok"
      "notion"
      "notion-calendar"
      "notion-mail"
      "obs"
      "obsidian"
      "openchamber"
      "opencode-desktop"
      "openlens"
      "orbstack"
      "orca"
      "palmier-pro"
      "paper-design"
      "parallels@20"
      "philips-hue-sync"
      "plaud"
      "raycast"
      "recordly"
      "screen-studio"
      "screenflow"
      "sf-symbols"
      "shearwater-cloud"
      "shottr"
      "slack"
      "slack-cli"
      "spotify"
      "superwhisper"
      "tailscale-app"
      "telegram"
      "teleport-connect"
      # JDKs, all pkg installs into /Library/Java/JavaVirtualMachines so
      # /usr/libexec/java_home finds them: latest, 21 LTS and Zulu 17 (zulu@17
      # below) for older Gradle builds.
      "temurin"
      "temurin@21"
      "warrensbox/tap/tfswitch"
      "tidal"
      "transmission"
      "typeless"
      "visual-studio-code"
      "vivaldi"
      "vlc"
      "vrew"
      "warp"
      "webstorm"
      "wezterm"
      "winbox"
      "wispr-flow"
      "xmind"
      "yes24-ebook"
      "zcode"
      "zed"
      "zoom"
      "zulu@17"
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
  # The NetBird client daemon, as `sudo netbird service install` writes it.
  # Keeping the label and arguments identical means `netbird service
  # start/stop/status` and `netbird up` keep working against this plist.
  launchd.daemons.netbird.serviceConfig = {
    Label = "netbird";
    ProgramArguments = [
      "/opt/homebrew/bin/netbird"
      "service"
      "run"
      "--log-level"
      "info"
      "--daemon-addr"
      "unix:///var/run/netbird.sock"
      "--log-file"
      "/var/log/netbird/client.log"
    ];
    Disabled = false;
    KeepAlive = true;
    RunAtLoad = false;
    SessionCreate = false;
    StandardErrorPath = "/var/log/netbird.err.log";
    StandardOutPath = "/var/log/netbird.out.log";
  };
}
