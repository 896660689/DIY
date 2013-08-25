# ~/.bashrc: executed by bash(1) for non-login shells.

export PS1='\h:\w\$ '
umask 01

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto --show-control-chars'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
alias dir='ls -la --show-control-chars'
#
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
#
# speed up grep
export LC_ALL=C
#
source /etc/nas/NSPT/setPerlVar
export PATH=/opt/bin:$PATH 
