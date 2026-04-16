#!/bin/bash

alias_if_command() {
    local alias_name="$1"
    shift

    if command -v "$1" >/dev/null 2>&1; then
        alias "$alias_name=$*"
    fi
}

alias_if_file() {
    local alias_name="$1"
    local target_path="$2"
    shift 2

    if [[ -e "$target_path" ]]; then
        alias "$alias_name=$target_path${*:+ $*}"
    fi
}

alias_if_file_with_prefix() {
    local alias_name="$1"
    local target_path="$2"
    shift 2

    if [[ -e "$target_path" ]]; then
        alias "$alias_name=$* $target_path"
    fi
}

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lh='ls -lh'
alias rm='rm -i'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

#My aliases
alias_if_command ipmi ipmitool -U ADMIN -P ADMIN -I lanplus -H '$BMC_IP'
alias_if_command pddipmi ipmitool -U admin -P Pdd@2015 -I lanplus -H '$PDD_IP'
alias_if_command sksipmi ipmitool -U admin -P kuaishou -I lanplus -H '$SEADRA_KS_IP'
alias_if_command btipmi ipmitool -U '$BT_USER_NAME' -P '$BT_PWD' -I lanplus -H
alias_if_command lcipmi ipmitool -U '$BT_USER_NAME' -P '$BT_PWD' -I lanplus -H 172.17.8.39
alias_if_file sublime "$HOME/softwares/sublime_text_3/sublime_text"
alias_if_file myHexToStr "$HOME/my_documents/documents/ownCode/c/HexToStr"
alias_if_file myBaseConv "$HOME/documents/ownCode/c/myconv"
alias_if_command killtask sudo pkill -9
alias pbuild='./B_Build.sh -b ~/softwares/mds_4.0.1'
alias prelease='./A_Release.sh -b ~/softwares/mds_4.0.1/'
alias_if_file acurl "$HOME/documents/my_tools/a_curl/ex_curl.sh"
alias_if_file ieccurl "$HOME/documents/my_tools/a_curl/iec_curl.sh"
alias tailf='tail -f'
alias_if_command minicom sudo minicom -c on -a on -w
alias_if_file delIpRoute "$HOME/ShellScript/delIpRoute.sh"
alias utool='sudo $UTOOL -U ADMIN -P ADMIN -H $BMC_IP'
alias_if_file crc_calc "$HOME/CRC_Calc/crc"
#alias vscode='code --user-data-dir $HOME/.vscode'
#alias vscode='/usr/share/code/code --new-window --user-data-dir $HOME/.vscode'
#alias code='/usr/share/code/code --user-data-dir $HOME/.vscode %F'
#alias myMinicom='$HOME/ShellScript/startMinicom/start_minicom.sh.x'
#alias rm='/bin/safe_rm.sh'
#alias rm='mv -n' 
#alias rm='$HOME/safe_rm.sh && safe_rm'
#

alias_if_file_with_prefix mac_set "$HOME/ShellScript/set_random_mac.sh" sudo /bin/bash
alias_if_file_with_prefix obmc_update "$HOME/myDisk/python/obmc_redfish/update_service/update_fw.py" python3

alias_if_file dpcmd "$HOME/myDisk/SF100Linux/dpcmd"
alias_if_file apc "$HOME/ShellScript/APCCtrl/APCControl.sh"
alias get_lx106='export PATH="$PATH:$HOME/esp/tool_chain/esp8266/xtensa-lx106-elf/bin"'

# alias cp='/usr/bin/cp -ig'
#alias mv='/usr/bin/mv -ig'

alias_if_file_with_prefix snvim "$HOME/.install/nvim-linux-x86_64/bin/nvim" sudo -E
alias_if_file obtool "$HOME/projects/ob-tool/ob_tools.py"

alias_if_file_with_prefix run-qemu "$HOME/projects/run_qemu/run-qemu.py" python3
