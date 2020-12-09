if [ -d /etc/X11/xinit/xinitrc.d ] ; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

setxkbmap fr &
/usr/bin/start-pulseaudio-x11 &
exec i3 --shmlog-size=26214400  > ~/i3.log 2>&1
# exec gnome-session
