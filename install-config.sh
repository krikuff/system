#! /usr/bin/env bash

set -ue

[ "$(id -u)" -ne 0 ] && { echo Permission denied ; exit 1; }

rsync -u configuration.nix fish_init.fish vimrc \
	/etc/nixos

