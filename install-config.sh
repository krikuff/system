#! /usr/bin/env bash

set -e

if [[ "`whoami`" != "root" ]]; then
	echo You have to be root to install configuration!
	exit
fi

cp configuration.nix /etc/nixos/
cp fish_init.nix /etc/nixos
cp vimrc.nix /etc/nixos
