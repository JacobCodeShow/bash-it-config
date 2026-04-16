#!/bin/bash
if [ -f ~/.git-completion.bash ];then
    source ~/.git-completion.bash
fi 

if [[ -f "/home/sysadmin/utool-1.31.00/Tencent-tlinux2.2/utool_centos-7.2.1511-x86_64/uTool" ]];then 
    export UTOOL=$HOME/utool-1.31.00/Tencent-tlinux2.2/utool_centos-7.2.1511-x86_64/uTool 
fi 

if [[ -f ~/.utool-completion.bash ]];then 
    source "~/.utool-completion.bash"
    complete -F Utool_AutoComplete utool 
    complete -F Utool_AutoComplete $UTOOL 
fi

if [[ -f $HOME/.gitpush-completion.bash ]];then 
    source $HOME/.gitpush-completion.bash 
    complete -F gitpush_completion gitpush
fi

if [[ -f ~/.getpro-completion.bash ]];then 
    source ~/.getpro-completion.bash 
    complete -F getpro_AutoComplete getProject 
fi