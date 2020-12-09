#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH=$PATH:/home/robin/bin
export PATH=/home/robin/.m2/wrapper/dists/apache-maven-3.6.3-bin/1iopthnavndlasol9gbrbg6bf2/apache-maven-3.6.3/bin:$PATH
export EDITOR=vim
alias ls='ls --color=auto'
alias ll='ls -l'
alias up='sudo pacman -Syu'
alias spd='systemctl suspend'
alias gst='git status'
alias lv='light -S 20'
alias kdb='killall dropbox'
PS1='[\u@\h \W]\$ '
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx 

if [[ "$TERM" == screen* ]]; then
     screen_set_window_title () {
         local DP="$BASH_COMMAND"
         if grep -q "printf" <<< "$DP"; then
             DP="bash"
         fi
         printf '\ek%s\e\\' "$DP"
     }
     # trap 'echo -e "\e]0;$BASH_COMMAND\007"' DEBUG
     trap 'screen_set_window_title;' DEBUG
fi
