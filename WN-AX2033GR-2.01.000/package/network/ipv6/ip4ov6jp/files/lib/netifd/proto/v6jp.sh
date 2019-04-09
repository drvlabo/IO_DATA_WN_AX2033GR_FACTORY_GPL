#!/bin/sh

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_v6jp_init_config() {
        echo "test"
}

proto_v6jp_setup() {
        local config="$1"
        local iface="$2"

        proto_init_update "ip4ov6jp0" 1 1
        proto_set_keep 1
        proto_send_update "wan"
}

proto_v6jp_renew() {
        #local interface="$1"
        # SIGUSR1 forces udhcpc to renew its lease
        #local sigusr1="$(kill -l SIGUSR1)"
        #[ -n "$sigusr1" ] && proto_kill_command "$interface" $sigusr1
        echo "test"
}

proto_v6jp_teardown() {
        #local interface="$1"
        #proto_kill_command "$interface"
        echo "test"
}

add_protocol v6jp
