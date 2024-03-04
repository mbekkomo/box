cmdinfo.help()
{
  summary="Prints this message and subcommand usage"
  args=("[subcommand]")
  args_summary=("A subcommand to see it's usage.")
  options=("-h, --help")
  options_summary=("Prints subcommand usage.")
  options_format=""
}

options_handler.help()
{
  utils.default_options_handler help "$@"
}

commands.help()
{
  if [[ -n "$errmsg" ]]; then
    declare opt="${errmsg##*' '}"
    {
      echo "Usage: ${0##*/} help [options] [subcommand]"
      echo
      echo "Error: unknown option \`$opt'"
    } >&2
    return 1
  fi

  declare summary command
  if (( !$# )); then
    echo "Usage: ${0##*/} <subcommand> [options] ..."
    echo
    echo "A Bash dependency manager."
    echo
    echo $'\e[1m━━━ Subcommands ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[m'

    while read -r cmd; do
      [[ "$cmd" == "declare -f commands."* ]] || continue
      : "${cmd##*-f commands.}"
      command="${_%%=*}"
      cmdinfo."$command"
      echo "  $command "$'\e[1m↴\e[m\n    '"$summary"
    done <<<"$(declare -pF)"

    echo
    echo "For more information, try add \`-h' flag to a subcommand or pass an subcommand to \`help'."
  elif [[ "$(type -t "commands.$1")" == "function" ]]; then
    cmdinfo."$1"
    echo "Usage: ${0##*/} $1 [options]${args[*]:+ ${args[*]}}"
    echo
    echo "${summary}"
    echo

    if (( ${#args[@]} )); then
      echo $'\e[1m━━━ Arguments ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[m'
      for i in "${!args[@]}"; do
        declare arg="${args[$i]}"
        echo "  $arg "$'\e[1m↴\e[m\n    '"${args_summary[$i]}"
      done
      echo
    fi

    if (( ${#options[@]} )); then
      echo $'\e[1m━━━ Options ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[m'
      for i in "${!options[@]}"; do
        declare opt="${options[$i]}"
        echo "  $opt "$'\e[1m↴\e[m\n    '"${options_summary[$i]}"
      done
    fi
  else
    {
      echo "Usage: ${0##*/} help [options] [subcommand]"
      echo
      echo "Error: unknown subcommand \`$1'"
    } >&2
    return 1
  fi
}
