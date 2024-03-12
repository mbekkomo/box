utils.detect_color()
{
  [[ -n "$NO_COLOR" ]] && return 1
  [[ "$FORCE_COLOR" == @(1|2|3) ]] && return 0
  [[ "$FORCE_COLOR" == "0" ]] && return 1
  [[ "$TERM" == "dumb" ]] && return 1
  [[ -n "$COLORTERM" ]] && return 0
  return 1
}

utils.detect_color
color_level="$?"

declare -A ansi_codes=(
  [reset]=0           [black]=30     [bgblack]=40
  [bold]=1            [red]=31       [bgred]=41
  [dim]=2             [green]=32     [bggreen]=42
  [italic]=3          [yellow]=33    [bgyellow]=43
  [underline]=4       [blue]=34      [bgblue]=44
  [blink]=5           [magenta]=35   [bgmagenta]=45
  [reverse]=7         [cyan]=36      [bgcyan]=46
  [hidden]=8          [white]=37     [bgwhite]=47
  [strikethrough]=9   [default]=39   [bgdefault]=49
)

utils.raw_color()
{
  (( color_level )) && return 1
  declare args=("$@")
  declare txt="${args[$#-1]}"
  while (( $# - 1 )); do
    printf -v buff "$buff\x1b[%dm" "${ansi_codes[$1]}"
    shift
  done
  printf "%s" "$buff$txt"
}

utils.color()
{
  printf "%s\x1b[m" "$(utils.raw_color "$@")"
}

utils.echo_color()
{
  utils.color "$@"
  echo
}
