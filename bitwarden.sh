#!/bin/sh
export ELECTRON_IS_DEV=0

# disable core dumps
ulimit -c 0

# memory protection: prevent debugger attachment and memory reads
export LD_PRELOAD=/usr/lib/bitwarden/libprocess_isolation.so

cd /usr/lib/bitwarden
exec electron@electronversion@ /usr/lib/bitwarden/app.asar $@
