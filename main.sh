#!/usr/bin/env bash
#i

#@include ./utils/*.sh
#@include ./commands/*.sh


(( $# )) || {
  commands.help >&2
  exit 1
}

declare command="$1"
shift
if [[ "$(type -t "commands.$command")" != "function" ]]; then
  echo "Usage: ${0##*/} <subcommand> [options] ..."
  echo
  echo "Error: unknown subcommand \`$command'"
  exit 1
fi

declare command_options_format="__${command}_options_format"

# shellcheck disable=SC2154 # it's in ./utils/commands.sh
utils.extopts "commands.${command}_options_handler" "$utils_default_options_format${!command_options_format:+ ${!command_options_format}}" "$@"
(( $? == 30 )) && exit
# shellcheck disable=SC2046 # it's intended
set -- $(utils.strip_options "$@")
commands."$command" "$@"
exit "$?"
