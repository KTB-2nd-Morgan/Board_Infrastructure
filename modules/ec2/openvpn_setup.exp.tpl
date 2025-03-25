#!/usr/bin/expect -f
set timeout 300

spawn /usr/local/openvpn_as/bin/ovpn-init

expect "Please enter 'yes' to indicate your agreement"
send "yes\r"

expect "Will this be the primary Access Server node?"
send "\r"

expect "Please specify the network interface"
send "\r"

expect "What public/private type/algorithms do you want to use for the OpenVPN CA?"
send "\r"

expect "What public/private type/algorithms do you want to use for the self-signed web certificate?"
send "\r"

expect "Please specify the port number for the Admin Web UI"
send "\r"

expect "Please specify the TCP port number for the OpenVPN Daemon"
send "\r"

expect "Should client traffic be routed by default through the VPN?"
send "\r"

expect "Should client DNS traffic be routed by default through the VPN?"
send "yes\r"

expect "Should private subnets be accessible to clients by default?"
send "\r"

expect "Do you wish to login to the Admin UI as \"openvpn\"?"
send "\r"

expect "Type a password for the 'openvpn' account"
send "${openvpn_password}\r"

expect "Confirm the password for the 'openvpn' account"
send "${openvpn_password}\r"

expect "Please specify your Activation key"
send "\r"

expect eof
