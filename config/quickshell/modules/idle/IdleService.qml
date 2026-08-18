import Quickshell.Io
import Quickshell.Wayland._IdleNotify
import QtQuick

Item {
    id: root

    required property var lockScreen

    // Stage 1 (150s): dim the display.
    IdleMonitor {
        timeout: 350
        onIsIdleChanged: {
            if (isIdle)
                dimOn.exec(["brightnessctl", "-s", "set", "10"]);
            else
                dimOff.exec(["brightnessctl", "-r"]);
        }
    }

    // Stage 2 (150s): turn off keyboard backlight.
    IdleMonitor {
        timeout: 350
        onIsIdleChanged: {
            if (isIdle)
                kbdOn.exec(["brightnessctl", "-sd", "rgb:kbd_backlight", "set", "0"]);
            else
                kbdOff.exec(["brightnessctl", "-rd", "rgb:kbd_backlight"]);
        }
    }

    // // Stage 3 (100s): hyprdvd screensaver.
    // IdleMonitor {
    //     timeout: 100
    //     onIsIdleChanged: {
    //         if (isIdle)
    //             dvdOn.exec(["sh", "-c", "brightnessctl -r; hyprctl dispatch exec 'hyprdvd -s'"]);
    //         else
    //             dvdOff.exec(["pkill", "hyprdvd"]);
    //     }
    // }

    // Stage 4 (300s): lock the session.
    IdleMonitor {
        timeout: 400
        onIsIdleChanged: {
            if (isIdle)
                root.lockScreen.lock();
        }
    }

    // Stage 5 (330s): DPMS off.
    IdleMonitor {
        timeout: 500
        onIsIdleChanged: {
            if (isIdle)
                dpmsOn.exec(["hyprctl", "dispatch", "dpms", "off"]);
            else
                dpmsOff.exec(["sh", "-c", "hyprctl dispatch dpms on; brightnessctl -r"]);
        }
    }

    // Stage 6 (1800s): suspend the system.
    IdleMonitor {
        timeout: 1800
        onIsIdleChanged: {
            if (isIdle)
                suspendProc.exec(["systemctl", "suspend"]);
        }
    }

    Process {
        id: dimOn
    }
    Process {
        id: dimOff
    }
    Process {
        id: kbdOn
    }
    Process {
        id: kbdOff
    }
    Process {
        id: dvdOn
    }
    Process {
        id: dvdOff
    }
    Process {
        id: dpmsOn
    }
    Process {
        id: dpmsOff
    }
    Process {
        id: suspendProc
    }

    // Mirrors hypridle's before_sleep_cmd/after_sleep_cmd: lock ahead of ANY
    // suspend (manual, lid close, or idle-triggered) and restore DPMS after
    // resume, by watching logind's own sleep signal directly.
    Process {
        id: sleepWatcher
        command: ["dbus-monitor", "--system", "type='signal',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'"]
        running: true

        property bool sawSignal: false

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (data.indexOf("member=PrepareForSleep") !== -1) {
                    sleepWatcher.sawSignal = true;
                    return;
                }
                if (!sleepWatcher.sawSignal)
                    return;
                sleepWatcher.sawSignal = false;
                if (data.indexOf("boolean true") !== -1)
                    root.lockScreen.lock();
                else if (data.indexOf("boolean false") !== -1)
                    dpmsOff.exec(["sh", "-c", "hyprctl dispatch dpms on; brightnessctl -r"]);
            }
        }

        onExited: restartTimer.restart()
    }

    Timer {
        id: restartTimer
        interval: 3000
        onTriggered: sleepWatcher.running = true
    }
}
