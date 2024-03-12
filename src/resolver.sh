# shellcheck disable=SC2317

resolver.validate_depname()
{
  for (( i=0; i<${#1}; i++ )); do
    declare s="${1:i:1}"
    [[ "$s" == [[:alnum:]_] ]] || return 1
    [[ "$(utils.tobyte "$s")" == [0-9a-f][0-9a-f] ]] || return 1
  done
}

resolver.parse_error()
{
  unset -f exit
  echo "Failed to parse boxfile.sh" >&2
  for s in "$@"; do
    msg.error "$s" >&2
  done
  exit 1
}

resolver.check_currentdep()
{
  [[ -R current_dep ]] ||
    resolver.parse_error "Trying to use directive $(utils.color cyan "${FUNCNAME[1]}") outside dependency scope."
}

resolver.get_named_params()
{
  declare -gxa param_all=()
  declare -n current_param=param_all
  while (( $# )); do
    [[ "$1" == *":" ]] && {
      unset -n current_param
      declare param_name="${1//-/_}"
      declare -n current_param="param_${param_name%:}"
      shift
      continue
    }
    current_param+=("$1")
    shift
  done
}

resolver.check_syntax()
{
  declare errs=()
  while read -r err; do
    [[ "$err" =~ line\ ([0-9]+?): ]]
    errs+=("In line ${BASH_REMATCH[1]}, ${err##*: }.")
  done < <(bash -n ./boxfile.sh 2>&1)
  (( ${#errs[@]} )) && resolver.parse_error "${errs[@]}"
}

resolver.parse_boxfile()
{
  declare -ga deps

  [[ -f ./boxfile.sh ]] ||
    resolver.parse_error "File not found."
  resolver.check_syntax
  
  declare oldpath="$PATH"
  export PATH=""
  declare builtins=(command exec trap exit set shopt builtin exit)
  utils.disable_builtin "${builtins[@]}"
  
  dependency()
  {
    resolver.validate_depname "$1" ||
      msg.parse_error "Dependency with identifier $(utils.color blue "$1") must only contain alphanumeric and underscore characters."
      
    declare depname="dep_$1"

    declare -gA "$depname"
    deps+=("$depname")
    [[ -R current_dep ]] &&
      unset -n current_dep

    declare -gn current_dep="$depname"
    current_dep+=(
      [id]="$1"
      [name]="$1"
    )
  }

  as()
  {
    resolver.check_currentdep
    current_dep+=(
      [name]="$(utils.strip_space "$1")"
    )
  }
  
  src()
  {
    resolver.check_currentdep
    declare type="$1"
    shift
    case "$type" in
      git|tarball)
        current_dep+=(
          [srctype]="$type"
          [srcurl]="$1"
        )
        ;;
      *)
        resolver.parse_error "Unknown source type $(utils.color blue "$type") in scope $(utils.color green "${current_dep[id]}")."

        ;;
    esac
  }

  hook()
  {
    resolver.check_currentdep
    resolver.get_named_params "$@"
    current_dep+=(
      [hook-atfetch]="$param_atfetch"
      [hook-atupdate]="$param_atupdate"
      [hook-atinstall]="$param_atinstall"
      [hook-externalcheck]="$param_externalcheck"
    )
  }

  install()
  {
    resolver.check_currentdep
    resolver.get_named_params "$@"
    declare oldifs="$IFS"
    IFS=$'\n'
    current_dep+=(
      [install-bin]="${param_bin[*]}"
      [install-script]="${param_script[*]}"
    )
    IFS="$oldifs"
  }

  depends()
  {
    resolver.check_currentdep
    declare -a dependencies
    while (( $# )); do
      dependencies+=("$1")
      shift
    done
    declare oldifs="$IFS"
    IFS=$'\n'
    current_dep+=(
      [dependencies]="${dependencies[*]}"
    )
    IFS="$oldifs"
  }

  source ./boxfile.sh
  
  unset -f "${builtins[@]}"
  unset -f dependency as src install hook depends
  unset -n current_dep
  unset current_dep
  export PATH="$oldpath"
}
