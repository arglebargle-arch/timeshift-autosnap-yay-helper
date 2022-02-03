#!/usr/bin/bash
#
# timeshift-autosnap helper for your AUR helper (autosnap-wrapper.sh)
#
# this helper code stops your AUR helper + timeshift-autosnap from taking multiple snapshots during the same update

# shellcheck disable=SC2155
export __AUTOSNAP_LOCK="$(mktemp -ut "aur-helper-autosnap.lock-XXXXXXX")"

# shellcheck disable=SC2064
trap "[[ -f $__AUTOSNAP_LOCK ]] && rm -f -- $__AUTOSNAP_LOCK" EXIT

# see hook /etc/pacman.d/hooks/00-timeshift-autosnap.hook for reference
exec "$(type -P $AUR_HELPER)" --sudoflags="--preserve-env=__AUTOSNAP_LOCK" "${@:--Syu}"
