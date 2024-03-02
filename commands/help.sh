__command_help="help"
__summary_help="Prints this message and subcommand usage."
__args_help=("[subcommand]")
__args_summary_help=("Usage of a subcommand.")
__options_help=("-h, --help")
__options_summary_help=("Prints usage of this subcommand.")
__help_options_format=""

commands.help_options_handler()
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
    echo "Usage: ${0##*/} subcommand [options] ..."
    echo
    echo "A Bash dependency manager."
    echo
    echo "===: Subcommands :==="

    while read -r var; do
      [[ "$var" == "declare -- __command_"* ]] || continue
      : "${var##*-- }"
      command="${_%%=*}"
      summary="__summary_${command##*_}"
      echo "  ${!command} "$'\e[1m↴\e[m\n    '"${!summary}"
    done <<<"$(declare -p)"

    echo
    echo "For more information, try add \`-h' flag to a subcommand or pass an subcommand to \`help'."
  elif [[ "$(type -t "commands.$1")" == "function" ]]; then
    summary="__summary_$1"
    declare -n args="__args_$1" args_summary="__args_summary_$1"
    declare -n options="__options_$1" options_summary="__options_summary_$1"

    echo "Usage: ${0##*/} $1 [options]${args[*]:+ ${args[*]}}"
    echo
    echo "${!summary}"
    echo

    if declare -p "__args_$1" >/dev/null 2>&1 && (( ${#args[@]} )); then
      echo "===: Arguments :==="
      for i in "${!args[@]}"; do
        declare arg="${args[$i]}"
        echo "  \`$arg' "$'\e[1m↴\e[m\n    '"${args_summary[$i]}"
      done
      echo
    fi

    if declare -p "__options_$1" >/dev/null 2>&1 \
    && (( ${#options[@]} ))
    then
      echo "===: Options :==="
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
  fi
}
