utils.tobyte()
{
  declare old_lc="$LC_ALL"
  LC_ALL=C
  for (( i=0; i<${#1}; i++ )); do
    printf "%x" "'${1:i:1}"
  done
  LC_ALL="$old_lc"
}

utils.strip_space()
{
  declare buff="$1"
  for (( i=0; i<${#buff}; i++ )); do
     if [[ "${buff:0:1}" == [[:space:]] ]]; then
       buff="${buff:1:${#buff}}"
     else
       break
     fi
  done
  for (( i=${#buff}-1; i>0; i-- )); do
    if [[ "${buff: -1}" == [[:space:]] ]]; then
      buff="${buff:0:${#buff}-1}"
    else
      break
    fi
  done
  echo "$buff"
}

utils.strip_escape_sequence()
{
  sed $'s/\e\\[.*?m//g' <<<"$1"
}
