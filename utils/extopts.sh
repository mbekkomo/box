# shellcheck shell=bash

utils.extopts()
{
  declare callback="$1" format="$2 "
  shift
  shift

  declare -A options options_needargs
  while read -r -d " " fmt; do
    declare iden="${fmt%%:*}" body="${fmt#*:}"
    declare longopt="${body#*/}" shortopt="${body%/*}"
    declare passarg=0
    [[ "$fmt" == *: ]] && passarg=1
  
    [[ "$longopt" == "." ]] || options["$longopt"]+="$iden"
    [[ "$shortopt" == "." ]] || options["$shortopt"]+="$iden"
    (( passarg )) && options_needargs["$iden"]=1
  done <<<"$format"

  while (( $# )); do
    [[ "$1" == -* ]] || { shift; continue; }
    declare err=0 errmsg opt="$1" iden arg

    if [[ -z "${options[$opt]}" ]]; then
      err=1
      errmsg="invalid option: $opt"
    else
      iden="${options[$opt]}"
    fi

    if (( !err && options_needargs["$iden"] )); then
      shift
      arg="$1"
    fi

    if (( err )); then
      "$callback" 1 "$errmsg"
      return 1
    else
      "$callback" 0 "$iden" "$arg" || return "$?"
    fi
    shift
  done
}
