#!/usr/bin/env bash

# Toggle wf-recorder. Captures desktop audio (the default sink's monitor)
# only -- never the mic, regardless of @DEFAULT_AUDIO_SOURCE@.

if pgrep -x wf-recorder >/dev/null; then
    pkill -x -INT wf-recorder
    notify-send 'Recording Stopped' 'Saved to ~/Videos/Recordings'
    exit 0
fi

mkdir -p ~/Videos/Recordings
filename=~/Videos/Recordings/$(date +%Y-%m-%d_%H-%M-%S).mp4
audio_source="$(pactl get-default-sink).monitor"

# Software x264 rather than the Intel Quick Sync hardware encoder (h264_vaapi):
# Quick Sync is fast and light on CPU, but it's visibly softer on text/UI
# detail than x264 at any bitrate -- that's what made recordings look
# sub-720p even at native resolution. x264 at "veryfast" only costs ~250%
# CPU on this 8-thread machine (vs. the ~300%+ "slow" preset that caused
# real lag earlier), which leaves plenty of headroom.
setsid wf-recorder -f "$filename" "--audio=$audio_source" \
    -r 60 -c libx264 -p crf=18 -p preset=veryfast \
    >/tmp/wf-recorder.log 2>&1 &
notify-send 'Recording Started' "$filename"
