set fish_greeting

# TODO: include the following
# if status is-interactive
#     # Commands to run in interactive sessions can go here
# end

set -x MANPAGER "sh -c 'col -bx | batcat -l man -p'"

fish_vi_key_bindings

# Git abbrs
abbr -a ga git add
abbr -a gba git branch --list -a
abbr -a gcl clone_n_switch.sh
# abbr -a gcm git commit -m
abbr -a gcf git commit -F commit_message
abbr -a gco git checkout
abbr -a gd git diff --patience
abbr -a gds git diff --shortstat
abbr -a gdc git diff --patience --cached
abbr -a glo git log --oneline
abbr -a gs git status
abbr -a gcp git cherry-pick
abbr -a gcpc git cherry-pick --continue

# Other abbrs
abbr -a df df -h
abbr -a du du -h
abbr -a s sudo
abbr -a v nvim
abbr -a ls exa
abbr -a ll exa -l
abbr -a lt exa -T -L 2

alias tote 'cp ~/Code/template.cpp'
alias fd fdfind
alias bat batcat

set -x EDITOR nvim

function my_prompt_login --description 'user@hostname, but hostname only if it is non-standard everyday localhost'
    if not set -q __fish_machine
        set -g __fish_machine
        set -l debian_chroot $debian_chroot

        if test -r /etc/debian_chroot
            set debian_chroot (cat /etc/debian_chroot)
        end

        if set -q debian_chroot[1]
            and test -n "$debian_chroot"
            set -g __fish_machine "(chroot:$debian_chroot)"
        end
    end

    # Prepend the chroot environment if present
    if set -q __fish_machine[1]
        echo -n -s (set_color yellow) "$__fish_machine" (set_color normal) ' '
    end

    set -l my_hostname ""

    # If we're running via SSH, change the host color.
    set -l color_host $fish_color_host
    if set -q SSH_TTY; and set -q fish_color_host_remote
        set color_host $fish_color_host_remote
        set my_hostname "@ (set_color $color_host) (prompt_hostname) (set_color normal)"
    end

    echo -n -s (set_color $fish_color_user) "$USER" (set_color normal) $my_hostname
end

function fish_prompt --description 'Write out the prompt'
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
    set -l normal (set_color normal)
    set -q fish_color_status
    or set -g fish_color_status red

    # Color the prompt differently when we're root
    set -l color_cwd $fish_color_cwd
    set -l suffix 'λ'
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    # Write pipestatus
    # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
    set -l bold_flag --bold
    set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
    if test $__fish_prompt_status_generation = $status_generation
        set bold_flag
    end
    set __fish_prompt_status_generation $status_generation
    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color $bold_flag $fish_color_status)
    set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

    echo -n -s -e (my_prompt_login)' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status "\n" $suffix " "
end

if not set -q TMUX
     echo "It would be better to run in tmux"
# https://medium.com/@HazuliFidastian/run-tmux-automatically-on-fish-shell-2b62622661c7
end
