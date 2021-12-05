#!/bin/bash

. /usr/lib/iserv/cfg

# Determines DHCP relay interfaces to listen on
#
# If DHCPRelay in /etc/iserv/config is set to the following values,
# the value of the IF variable will be set to:
#  - '*': Use all interfaces with private IPv4 addessses assigned. If none
#    exist, the IF variable is empty.
#  - one or more specific interfaces: Use these values and always configure the
#    DHCP server. This may fail if interfaces are specified that do not exist.
#    To make this clear, the iservchk script below checks the configured network
#    interfaces.
#  - empty: IF variable will be empty

if [ -z "${DHCPRelayServers[*]}" ]
then
  # No relay server, do not operate
  IF=
elif [ "${DHCPRelay[*]}" == "*" ]
then
  # Use all network interfaces with private IP addresses if existent
  IF="$(netquery -npr if)" || IF=""
else
  # Use specified interfaces from /etc/iserv/config
  IF="${DHCPRelay[@]}"
fi

if [ -n "$IF" ]
then
	# Prevent command injection
	{ [[ "$IF" =~ ^([a-zA-Z0-9][a-zA-Z0-9:._@-]+[a-zA-Z0-9][ ]?)+$ ]] && IF="$(echo "$IF" | sed -E "s/([^ ]+)/'\1'/g")"; } || IF="";

	cat <<-EOF
	Start isc-dhcp-relay dhcrelay

	EOF
else
	cat <<-EOF
	Stop isc-dhcp-relay dhcrelay

	EOF
fi

exit 0


