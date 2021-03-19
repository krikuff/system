set fish_greeting

abbr -ga bat bat -pp
abbr -ga cal cal --monday
abbr -ga df df -h
abbr -ga e exa
abbr -ga la exa --git -lha
abbr -ga ll exa --git -lh
abbr -ga lt exa --git -lhTL
abbr -ga v nvim

# git abbrs
abbr -ga ga git add
abbr -ga gba git branch --list -a
abbr -ga gcm git commit -m
abbr -ga gco git chekout
abbr -ga gd git diff --patience
abbr -ga glo git log --oneline
abbr -ga gs git status

set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

function file-rev-parse -a absolute_path request -d 'Search for the requested filename in all the directories up starting from absolute_path'
  while [ -n $absolute_path ]
    [ -e "$absolute_path/$request" ] ;and return 0

    set absolute_path (echo $absolute_path | awk -F/ 'OFS="/" {NF--; print}')
  end

  return 1
end

function fish_prompt -d "Write out the prompt"
  set -l color_cwd
  set -l prefix

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

  echo -ns [ ' ' (date +"%H:%M") ' | ' "$USER" '@' "$hostname" ' | '
  echo -ns (set_color $color_cwd) (prompt_pwd) (set_color normal)

  # TODO: optimise rev-parse
  file-rev-parse (pwd) Cargo.toml ;and echo -n ':🦀'
  file-rev-parse (pwd) CMakeLists.txt ;and echo -ns ':' (set_color $color_cwd) 'C/C++' (set_color normal)

  set current_git_dir (git rev-parse --git-dir 2> /dev/null)
  [ -n "$current_git_dir" ] ;and echo -ns ':' (set_color FF00FF) (git symbolic-ref --short HEAD) (set_color normal)

  echo -ns ' ' ] \n "$prefix "
end
