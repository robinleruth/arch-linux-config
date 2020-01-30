#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH=$PATH:/home/robin/bin
export FLASK_APP=~/Document/Git/toDoList/todolist.py
export FLASK_DEBUG=1
alias ls='ls --color=auto'
alias ll='ls -l'
alias up='sudo pacman -Syu'
alias spd='systemctl suspend'
PS1='[\u@\h \W]\$ '
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
