set fish_greeting

function file-rev-parse --argument absolute_path --argument request -d 'Searches current and every parent dir for given file'
  while [ -n $absolute_path ]
    if [ -e $absolute_path/$request ]
      return 0
    end

    set absolute_path (echo $absolute_path | awk -F/ 'OFS="/" {NF--; print}' )
  end

  return 1
end

function fish_prompt  --description "Write out the prompt"
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

  set current_git_dir (git rev-parse --git-dir 2> /dev/null)

  echo -n -s [ ' ' (date +"%H:%M") ' | ' "$USER" '@' "$hostname" ' | '
  echo -n -s (set_color $color_cwd) (prompt_pwd) (set_color normal)

  # TODO: optimise rev-parse
  if file-rev-parse (pwd) Cargo.toml
  echo -n -s ':🦀'
  end

  if file-rev-parse (pwd) CMakeLists.txt
  echo -n -s ':' (set_color $color_cwd) 'C/C++' (set_color normal)
  end

  if [ -n "$current_git_dir" ]
    echo -n -s ':' (set_color FF00FF) (git symbolic-ref --short HEAD) (set_color normal)
  end

  echo -s ' ' ]

  echo -n -s "$prefix "
end
