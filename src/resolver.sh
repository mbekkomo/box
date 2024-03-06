## simple package resolver

core.resolver.temp_dir()
{
  echo "./.box/temp/$1"
}

core.resolver.parse_boxfile()
{
  declare oldpath="$PATH"
  export PATH=""
  utils.disable_builtin command exec trap

  declare -ga deps
  declare i=1
  
  dependency()
  {
    declare depname="dep_$i"
    (( i++ ))

    declare -gA "$depname"
    deps+=("$depname")
    [[ "$(declare -p current_dep 2>/dev/null)" == "declare -n"* ]] &&
      unset -n current_dep

    declare -gn current_dep="$depname"
    current_dep+=(
      [dependency]="$1"
    )
  }
  
  src()
  {
    declare type="$1"
    shift
    case "$type" in
      git|tarball)
        current_dep+=(
          [srctype]="$type"
          [srcurl]="$1"
        )
        ;;
      external)
        current_dep+=(
          [srctype]=external
        )
        ;;
    esac
  }



  source ./boxfile.sh
  
  unset -f command exec trap
  unset -f dependency src
  unset -n current_dep
  unset current_dep
  export PATH="$oldpath"
}
