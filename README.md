timeshift-autosnap wrapper for your AUR helper (tested to work with yay and paru)

This code stops your AUR helper and timeshift-autosnap from taking multiple snapshots during updates.

### How to Install:

Move timeshift-autosnap-wrapper.sh to somewhere in your path (e.g. ~/.local/bin) and call it instead of your AUR helper
before updating,then move 00-timeshift-autosnap.hook into /etc/pacman.d/hooks/ to override the original autosnap hook. 
Finally write `export AUR_HELPER=EXAMPLE` into your .profile, replacing EXAMPLE with the one you use (in lowercase).

### The Problem:

AUR helpers invoke pacman multiple times during any given system update and the timeshift-autosnap hook dutifully
fires every time pacman is invoked to update packages. This often means that multiple partial-update snapshots are
taken during an upgrade; this makes timeshift-autosnap's function much less useful and adds clutter to our system.

### Our Solution:

We need some way to indicate to the various spawned pacman processes that we have (or haven't) made a snapshot during
an update. First we'll setup a location for a lockfile whose presence indicates that we've made a snapshot, save that
in an environment variable and then pass this through to each instance of pacman spawned by our AUR helper.

On first run the autosnap hook sees that our env var is declared but the file doesnt yet exist so we'll touch
the file as the user who called pacman via sudo and then proceed. On subsequent runs the lockfile exists so we
set the `SKIP_AUTOSNAP` variable before running `timeshift-autosnap` and no snapshot is created. On exit, after
our AUR helper is completely done, our wrapper script removes our lockfile as a final cleanup step

All of these things only ever happen if yay is launched through the wrapper script and '__AUTOSNAP_LOCK'
is defined; otherwise timeshift-autosnap is invoked normally without modification
