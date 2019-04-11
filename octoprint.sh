#!/bin/bash

set -e

die() {
    echo "Error: $@"
    exit 1
}

[[ -n "$PRINTER_IP_PORT" ]] || \
    die Env. var. \$PRINTER_IP_PORT must specify colon separated IP and port

[[ -n "$HOME" ]] || \
    die Env. var. \$HOME is not set

[[ -d "$HOME/venv" ]] || \
    die Expecting to find directory $HOME/venv

[[ -r "$HOME/.octoprint/config.yaml" ]] || \
    die Expecting configuration directory at $HOME/octoprint

while sleep 5s
do
    socat \
        -L$HOME/.socat.lock \
        pty,wait-slave,link=$HOME/printer,perm=0660,echo=0 \
        tcp:$PRINTER_IP_PORT,connect-timeout=10
done &

source venv/bin/activate
exec $@
