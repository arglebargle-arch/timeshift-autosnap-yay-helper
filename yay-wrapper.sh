#!/usr/bin/bash
#set -x

# timeshift-autosnap helper for yay (yay-wrapper.sh)

# this helper code stops yay + timeshift-autosnap from taking multiple snapshots during the same update

# stick this somewhere in your path and either call it instead of yay or 'alias yay=yay-wrapper.sh'
# then stick 00-timeshift-autosnap.hook in /etc/pacman.d/hooks/ to override the original autosnap hook

# how we solve the problem:

# we need some way to indicate to the various spawned pacman processes that we have (or haven't) run
# once during a yay invocation. we'll setup a location for a common lockfile, save that in an
# environment variable and then pass this env var through to all instances of pacman spawned by yay.

# on first run the autosnap hook sees that our env var is declared but the file doesnt yet exist
# so we'll touch the file as the user who called pacman via sudo (ie: the user running yay) and then
# proceed. On subsequent runs the lockfile exists so we set the SKIP_AUTOSNAP variable before running
# `timeshift-autosnap` and no snapshot is created. on exit, after yay is completely done, our EXIT hook
# (below) removes our lockfile

# all of these things only ever happen if yay is launched through the wrapper script and '__AUTOSNAP_LOCK'
# is defined; otherwise everything proceeds normally with no modification whatsoever

__AUTOSNAP_LOCK="$(mktemp -ut "yay-autosnap.lock-XXXXXXX")"
export __AUTOSNAP_LOCK

_onexit() {
	if [ -f "$1" ]; then
    printf "%s: " "$(basename "$0")"
    rm -fv -- "$1"
	fi
}
trap "_onexit $__AUTOSNAP_LOCK" EXIT

"$(type -P yay)" --sudoflags="--preserve-env=__AUTOSNAP_LOCK" "$@"

# hook (/etc/pacman.d/hooks/00-timeshift-autosnap.hook) code fragment for reference:

# Exec = /usr/bin/bash -c '[ -v "__AUTOSNAP_LOCK" ] && if [ -f "$__AUTOSNAP_LOCK" ]; then export SKIP_AUTOSNAP=":)"; else sudo -u ${SUDO_USER} touch "$__AUTOSNAP_LOCK"; fi; /usr/bin/timeshift-autosnap'
