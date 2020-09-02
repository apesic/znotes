#! /bin/zsh

function notes-home
{
  emulate -L zsh
  local p
  zstyle -s :notes home p || p="${HOME}/Notes"
  builtin print -rl "${p%/}"
}

function notes-list-files
{
  emulate -L zsh
  local H=$(notes-home)
  print -nrl $(fd . --extension md $H | sed -n "s@^$H/\(.*\)\.md@\1@p")
}

function __notes-pick
{
  emulate -L zsh
  local H=$(notes-home)
  local previewcmd="bat -l md --color always --theme OneHalfDark"
  local -a cmd=(
    fzf
    --bind=ctrl-n:print-query
    --prompt='[notes] '
    --reverse
    --height=50%
    --min-height=10
    --preview="$previewcmd $H/{}.md"
    --bind=tab:toggle-preview
    --preview-window=right:75%
    "$@"
  )

  local chosen=$("notes-list-files" | "$cmd[@]" "$@")
  if [[ -z ${chosen} ]] ; then
    return 1
  fi

  print -rl "$H/$chosen.md"
}

function notes-pick-widget
{
  emulate -L zsh
	setopt local_options err_return

  local chosen=$(__notes-pick)
  echo $chosen
  if [[ ! -z ${chosen} ]] ; then
    command "${EDITOR}" "${chosen}" < /dev/tty
  fi

  zle redisplay
}

zle -N notes-pick-widget
