#!/usr/bin/env bash

amalgs.include()
{
  cat "$@" | sed 's/^#\(#\|!\).*//'
}

cmd="$1"
shift
amalgs."$cmd" "$@"
