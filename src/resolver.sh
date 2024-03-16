# shellcheck disable=SC2317

resolver_msg_reset=$(utils.raw_color red '')

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
  utils.echo_color cyan "Failed to parse Box.sh" >&2
  for s in "$@"; do
    utils.color dim red "» "
    utils.echo_color red "$*"
  done >&2
  exit 1
}

resolver.check_currentdep()
{
  [[ -R current_dep ]] || {
    resolver.parse_error "Trying to use directive $(utils.color blue "${FUNCNAME[1]}")$resolver_msg_reset outside dependency scope."
  }
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
  done < <(bash -n ./Box.sh 2>&1)
  (( ${#errs[@]} )) && resolver.parse_error "${errs[@]}"
}

resolver.parse_boxfile()
{
  declare -ga project_dependencies

  [[ -f ./Box.sh ]] ||
    resolver.parse_error "File not found."
  resolver.check_syntax
  
  declare oldpath="$PATH"
  export PATH=""
  declare builtins=(command exec trap exit set shopt builtin exit)
  utils.disable_builtin "${builtins[@]}"
  
  dependency()
  {
    resolver.validate_depname "$1" ||
      resolver.parse_error "Dependency with identifier $(utils.color blue "$1")$resolver_msg_reset must only contain alphanumeric and underscore characters."
      
    declare dependency_name="dep_$1"

    declare -gA "$dependency_name"
    project_dependencies+=("$dependency_name")
    [[ -R dependency ]] &&
      unset -n dependency

    declare -gn dependency="$dependency_name"
    dependency+=(
      [id]="$1"
      [name]="$1"
    )
  }

  as()
  {
    resolver.check_currentdep
    dependency+=(
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
        dependency+=(
          [srctype]="$type"
          [srcurl]="$1"
        )
        ;;
      *)
        resolver.parse_error "Unknown source type $(utils.color blue "$type")$resolver_msg_reset in scope $(utils.color blue "${dependency[id]}")$resolver_msg_reset."

        ;;
    esac
  }

  hook()
  {
    resolver.check_currentdep
    resolver.get_named_params "$@"
    dependency+=(
      [hook-atfetch]="$param_atfetch"
      [hook-atupdate]="$param_atupdate"
      [hook-atinstall]="$param_atinstall"
    )
  }

  install()
  {
    resolver.check_currentdep
    resolver.get_named_params "$@"
    declare oldifs="$IFS"
    IFS=$'\n'
    dependency+=(
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
    dependency+=(
      [dependencies]="${dependencies[*]}"
    )
    IFS="$oldifs"
  }

  declare output
  output="$(source ./Box.sh 2>&1)"

  # shellcheck disable=SC2181
  (( $? )) &&
    resolver.parse_error $'Parsing the file returned non-zero exit code:\n'"${output:- <no output>}"
  
  unset -f "${builtins[@]}"
  unset -f dependency as src install hook depends
  unset -n dependency
  unset dependency
  export PATH="$oldpath"
}

declare -A resolver_fetch_sources=(
  [git]="git"
)

resolver.install_dependencies()
{
  for dep in "${project_dependencies}"; do
    declare -n dependency="$dep"
    
    echo
    utils.echo_color cyan "Installing $(utils.color green "${dependency[name]}")"
    echo
    utils.color cyan ""
}
