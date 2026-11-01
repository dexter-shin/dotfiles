#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# sudo resets PATH to a secure default that drops /run/current-system/sw/bin,
# so darwin-rebuild has to be invoked by its absolute path. Use the system
# profile, not /run/current-system: /run is cleared at boot and only the
# org.nixos.activate-system daemon recreates it, and that daemon can be unloaded.
exec sudo /nix/var/nix/profiles/system/sw/bin/darwin-rebuild switch --flake ~/.dotfiles#mac
