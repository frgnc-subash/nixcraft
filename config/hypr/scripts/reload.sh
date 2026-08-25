#!/usr/bin/env bash

hyprctl reload

if qs list 2>/dev/null | grep -q .; then
    qs ipc call shell reload
else
    qs &
    disown
fi
