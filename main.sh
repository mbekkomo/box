#!/usr/bin/env bash

#@include ./utils/*.sh
#@include ./commands/*.sh

(( $# )) || {
  commands.help >&2
  exit 1
}

declare command="$1"
shift
if [[ "$(type -t "commands.$command")" != "function" ]]; then
  {
    echo "Usage: ${0##*/} <subcommand> [options] ..."
    echo
    echo "Error: unknown subcommand \`$command'"
  } >&2
  exit 1
fi

cmdinfo."$command"

# shellcheck disable=SC2154 # it's in ./utils/commands.sh
utils.extopts "options_handler.${command}" "$utils_default_options_format${options_format:+ $options_format}" "$@"
(( $? == 30 )) && exit

# shellcheck disable=SC2046 # it's intended
set -- $(utils.strip_options "$@")

commands."$command" "$@"
