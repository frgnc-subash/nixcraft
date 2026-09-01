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
render_node=/dev/dri/renderD128

# Prefer the Intel iGPU's hardware encoder (Quick Sync) -- it's what
# Hyprland itself renders on -- so CPU usage stays low and frames don't
# drop under load. Falls back to a light software encode until the
# intel-media-driver package (added to modules/system/gpu/default.nix) has
# actually been switched to; that package is what provides this .so.
if [[ -e /run/opengl-driver/lib/dri/iHD_drv_video.so ]]; then
    video_args=(-c h264_vaapi -d "$render_node" -F "scale_vaapi=format=nv12" -r 60)
else
    video_args=(-r 60 -c libx264 -p crf=20 -p preset=veryfast)
fi

setsid wf-recorder -f "$filename" "--audio=$audio_source" "${video_args[@]}" >/tmp/wf-recorder.log 2>&1 &
notify-send 'Recording Started' "$filename"
