#!/usr/bin/bash
#
# timeshift-autosnap helper for yay (yay-wrapper.sh)
#
# this helper code stops yay + timeshift-autosnap from taking multiple snapshots during the same update

__AUTOSNAP_LOCK="$(mktemp -ut "yay-autosnap.lock-XXXXXXX")"
export __AUTOSNAP_LOCK

_onexit() {
	if [[ -f "$1" ]]; then
    printf "%s: " "$(basename "$0")"
    rm -fv -- "$1"
	fi
}
# shellcheck disable=SC2064
trap "_onexit $__AUTOSNAP_LOCK" EXIT

"$(type -P yay)" --sudoflags="--preserve-env=__AUTOSNAP_LOCK" "$@"

# see hook /etc/pacman.d/hooks/00-timeshift-autosnap.hook for reference
