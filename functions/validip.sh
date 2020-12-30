############# IP Verification Function, Not implemented yet ##################
ipvalid() {
  # Set up local variables
  local ip=$1
  local IFS=.; local -a a=($ip)
  # Start with a regex format test
  [[ $ip =~ ^[0-9]+(\.[0-9]+){3}$ ]] || return 1
  # Test values of quads
  local quad
  for quad in {0..3}; do
    [[ "${a[$quad]}" -gt 255 ]] && return 1
  done
  return 0
}

if ipvalid "$ip"; then
  echo "success ($ip)"
  exit 0
else
  echo "fail ($ip)"
  exit 1
fi
###########################################################################