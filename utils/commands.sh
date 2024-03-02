declare -x utils_default_options_format="help:-h/--help"
utils.default_options_handler()
{
  declare command="$1"
  shift
  (( $1 )) && {
    declare -x errmsg="$2"
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
  set -- "${args[@]}"
}
