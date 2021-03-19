#! /usr/bin/env bash

set -ue

[ "$(id -u)" -ne 0 ] && { echo Permission denied ; exit 1; }

install_path=${1:-'/etc/nixos'}

config_files=$(ls | grep -vf non-config-files)

# Erase files which are not in the current configuration set. The only exception is
# hardware configuration file
garbage_files=$(ls $install_path | grep -vx "$config_files" | grep -v "hardware-configuration.nix" || echo "")
if [ -n "$garbage_files" ]; then
    garbage_files_full=''
    for i in $garbage_files; do
        garbage_files_full+="$install_path/$i "
    done

    echo 'Erasing garbage files in /etc/nixos'
    echo $garbage_files_full
    rm -f $garbage_files_full
fi

# Actual installation
rsync -u $config_files $install_path

