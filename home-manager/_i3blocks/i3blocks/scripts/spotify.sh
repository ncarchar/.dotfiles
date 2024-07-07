#!/usr/bin/env bash

if pgrep "spotify" > /dev/null; then
    title=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | egrep -A 1 "title" | cut -b 44- | cut -d '"' -f 1 | egrep -v '^$')
    artist=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | egrep -A 2 "artist" | cut -b 20- | cut -d '"' -f 2 | egrep -v '^$' | egrep -v 'array|artist')

    if [[ -n $artist && -n $title ]]; then
        echo "$title"
    fi
else
    echo ""
fi
