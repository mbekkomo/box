declare -x utils_default_options_format="help:-h/--help"
utils.default_options_handler()
{
  declare command="$1"
  shift
  (( $1 )) && {
    declare -gx errmsg="$2"
    return 1
  }

  case "$2" in
    help) commands.help "$command"; return 30;;
  esac
}

utils.strip_options()
{
  declare args=("$@")
  for i in "${!args[@]}"; do
    declare arg="${args[$i]}"
    [[ "$arg" == -* ]] && unset "args[$i]"
    [[ "$arg" == -- ]] && break
  done
  echo "${args[@]}"
}

utils.has_command()
{
  command -v "$1" >/dev/null
}
