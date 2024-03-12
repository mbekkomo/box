log_names=(
  trace debug info
  warn error fatal
)

log_colors=(
  cyan blue green
  yellow red magenta
)

declare -A log_levels
for i in "${!log_names[@]}"; do
  # shellcheck disable=SC2034
  log_levels[${log_names[$i]}]=$i
done

# shellcheck disable=SC2016
log_func='
log.%s()
{
  (( %d < log_levels[$log_level] )) ||
    echo "[$(utils.color %s %s)] $*"
}
'

for i in "${!log_names[@]}"; do
  name="${log_names[$i]}"
  # shellcheck disable=2059
  printf -v func "$log_func" "$name" "$i" "${log_colors[$i]}" "$name"
  eval "$func"
done
