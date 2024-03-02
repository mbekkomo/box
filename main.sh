#!/usr/bin/env bash

#@include ./utils/*.sh
#@include ./commands/*.sh

(( $# )) || {
  commands.help >&2
  exit 1
}

declare command="$1"
shift
declare command_options_format="__${command}_options_format"

# shellcheck disable=SC2154 # it's in ./utils/commands.sh
utils.extopts "commands.${command}_options_handler" "$utils_default_options_format${!command_options_format:+ ${!command_options_format}}" "$@"
(( $? == 30 )) && exit
set -- $(utils.strip_options "$@")
commands."$command" "$@"
exit "$?"
