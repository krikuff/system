set fish_greeting

# TODO: include the following
# if status is-interactive
#     # Commands to run in interactive sessions can go here
# end

set -x MANPAGER "sh -c 'col -bx | batcat -l man -p'"
set EDITOR vim

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
# set -x TERM "xterm-256color" # WTF was kitty for long time

function file-rev-parse -a absolute_path request -d 'Search for the requested filename in all the directories up starting from absolute_path'
  while [ -n $absolute_path ]
    [ -e "$absolute_path/$request" ] ;and return 0

    set absolute_path (echo $absolute_path | awk -F/ 'OFS="/" {NF--; print}')
  end

  return 1
end

function fish_prompt_old -d "Write out the prompt"
  set -l color_cwd
  set -l prefix
  #set -x hostname (hostname)

  switch "$USER"
    case root toor
      if set -q fish_color_cwd_root
        set color_cwd $fish_color_cwd_root
      else
        set color_cwd $fish_color_cwd
      end
      set prefix '#'
    case '*'
      set color_cwd $fish_color_cwd
      set prefix 'λ'
  end

  echo -ns [ ' ' (date +"%H:%M") ' | ' "$USER" ' | '
  echo -ns (set_color $color_cwd) (prompt_pwd) (set_color normal)

  # TODO: optimise rev-parse
  file-rev-parse (pwd) Cargo.toml ;and echo -n ': 🦀'
  file-rev-parse (pwd) CMakeLists.txt ;and echo -ns ' : ' (set_color $color_cwd) 'C/C++' (set_color normal)

  set git_dir (git rev-parse --git-dir 2> /dev/null)
  if test -n "$git_dir"
    set git_branch (git symbolic-ref --short HEAD 2> /dev/null)
    if test -n "$git_branch"
      set git_string "$git_branch"
    else
      set git_tag (git describe --tags 2> /dev/null)
      if test -n "$git_tag"
        set git_string "🏷️$git_tag"
      end
    end
  end

  [ -n "$git_string" ] ;and echo -ns ' : ' (set_color FF00FF) "$git_string" (set_color normal)

  echo -ns ' ' ] \n "$prefix "
end

function my_prompt_login --description 'display user name for the prompt'
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
    set -l suffix '>'
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

    echo -n -s (my_prompt_login)' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status $suffix " "
end

if not set -q TMUX
     echo "TODO: Make tmux run at start"
# https://medium.com/@HazuliFidastian/run-tmux-automatically-on-fish-shell-2b62622661c7
end
