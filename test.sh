spin()
{
  declare spinner=("—" "\\" "|" "/")
  declare i=0
  while :; do
    (( i > 3 )) && i=0
    printf "\r%s test" "${spinner[$i]}"
    sleep 1
    (( i++ ))
  done &
  declare pid="$!"
  "$@" &
  wait "$!"
  kill "$pid"
}

spin sleep 10
