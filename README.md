timeshift-autosnap helper for yay (yay-wrapper.sh)

this helper code stops yay + timeshift-autosnap from taking multiple snapshots during updates

stick `yay-wrapper.sh` somewhere in your path and either call it instead of yay or 'alias yay=yay-wrapper.sh'
then stick 00-timeshift-autosnap.hook in /etc/pacman.d/hooks/ to override the original autosnap hook.

the problem:

yay can (and usually does) invoke pacman multiple times during any given system update and the timeshift-autosnap
hook dutifully fires every time pacman is invoked to update packages. This often means that multiple partial-update
snapshots are taken during an upgrade; this makes timeshift-autosnap's "num snapshots to keep" history much less
useful and adds partially-updated snapshots as clutter.

our solution:

we need some way to indicate to the various spawned pacman processes that we have (or haven't) made a
snapshot during a yay invocation. we'll setup a location for a lockfile whose presence indicates
that we've made a snapshot, save that in an environment variable and then pass this env var through to
each instance of pacman spawned by yay.

on first run the autosnap hook sees that our env var is declared but the file doesnt yet exist so we'll
touch the file as the user who called pacman via sudo (ie: the user running yay) and then proceed. On
subsequent runs the lockfile exists so we set the `SKIP_AUTOSNAP` variable before running `timeshift-autosnap`
and no snapshot is created. on exit, after yay is completely done, our yay-wrapper script removes our lockfile
as a final cleanup step

all of these things only ever happen if yay is launched through the wrapper script and '__AUTOSNAP_LOCK'
is defined; otherwise timeshift-autosnap is invoked normally without modification

