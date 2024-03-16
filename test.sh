spin()
{
  declare spinner=("⢎⡰" "⢎⡡" "⢎⡑" "⢎⠱" "⠎⡱" "⢊⡱" "⢌⡱" "⢆⡱")
  declare i=0
  while :; do
    (( i > (${#spinner[@]}-1) )) && i=0
    printf "\r%s test" "${spinner[$i]}"
    sleep .3
    (( i++ ))
  done &
  declare pid="$!"
  "$@" &
  wait "$!"
  kill "$pid"
}

. src/utils/string.sh
. src/utils/builtin.sh
. src/utils/ansi.sh
. src/resolver.sh

resolver.parse_boxfile
