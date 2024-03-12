utils.disable_builtin()
{
  while (( $# )); do
    eval "$1() { :; }"
    shift
  done
}
