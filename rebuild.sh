#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
# sudo resets PATH to a secure default that drops /run/current-system/sw/bin,
# so darwin-rebuild has to be invoked by its absolute path. nix-darwin keeps
# /run/current-system pointing at the active generation, so this always exists
# once bootstrap.sh has switched the machine once.
exec sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/.dotfiles#mac
