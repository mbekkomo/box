#!/usr/bin/env bash

shopt -s extglob

amalgs.include()
{
  cat "$@" | sed 's/^#\(#\|!\).*//'
}

cmd="$1"
shift
eval "amalgs.$cmd $*"
