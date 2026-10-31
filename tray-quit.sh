#!/bin/sh
# Quit the app that owns a tray icon, given the icon's StatusNotifierItem Id.
# Used by the bar's tray menu "Quit" entry:  tray-quit.sh <item id>
#
# The D-Bus owner of a tray icon isn't always the app itself, so:
#   Flatpak app         -> flatpak kill <app id>      (owner is xdg-dbus-proxy)
#   systemd user unit   -> systemctl --user stop      (a plain kill may just restart it)
#   XEmbed proxy        -> refuse (killing it drops every legacy tray icon)
#   anything else       -> SIGTERM the owning process
set -eu
want="$1"

items=$(busctl --user get-property org.kde.StatusNotifierWatcher /StatusNotifierWatcher \
        org.kde.StatusNotifierWatcher RegisteredStatusNotifierItems | grep -oE '"[^"]+"' | tr -d '"')

for item in $items; do
    svc=${item%%/*}
    obj=/${item#*/}
    id=$(busctl --user get-property "$svc" "$obj" org.kde.StatusNotifierItem Id 2>/dev/null \
         | sed -n 's/^s "\(.*\)"$/\1/p') || continue
    [ "$id" = "$want" ] || continue

    pid=$(busctl --user call org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus \
          GetConnectionUnixProcessID s "$svc" | awk '{print $2}')
    comm=$(cat "/proc/$pid/comm")
    cgroup=$(sed -n 's/^0:://p' "/proc/$pid/cgroup")
    unit=${cgroup##*/}

    case "$comm" in
        xembedsniproxy|snixembed)
            echo "tray-quit: $want is behind $comm, not quitting" >&2; exit 1 ;;
    esac
    case "$unit" in
        app-flatpak-*.scope)
            app=${unit#app-flatpak-}; app=${app%-*.scope}
            exec flatpak kill "$app" ;;
        *.service)
            exec systemctl --user stop "$unit" ;;
        *)
            exec kill -TERM "$pid" ;;
    esac
done

echo "tray-quit: no tray item with id $want" >&2
exit 1
