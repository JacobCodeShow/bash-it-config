#!/bin/bash
set -e

check_command() {
    local name="$1"

    if command -v "$name" >/dev/null 2>&1; then
        printf '[OK] command: %s\n' "$name"
    else
        printf '[WARN] missing command: %s\n' "$name"
    fi
}

check_path() {
    local path="$1"

    if [[ -e "$path" ]]; then
        printf '[OK] path: %s\n' "$path"
    else
        printf '[WARN] missing path: %s\n' "$path"
    fi
}

echo '== Required commands =='
for cmd in bash git curl grep awk; do
    check_command "$cmd"
done

echo
echo '== Recommended commands =='
for cmd in rsync dircolors tput; do
    check_command "$cmd"
done

echo
echo '== Optional tools =='
for cmd in atuin autojump ipmitool python3; do
    check_command "$cmd"
done

echo
echo '== Expected user paths =='
for path in \
    "$HOME/.install/nvim-linux-x86_64/bin/nvim" \
    "$HOME/.local/bin" \
    "$HOME/ShellScript" \
    "$HOME/myDisk" \
    "$HOME/projects" \
    "$HOME/esp/tool_chain/esp8266/xtensa-lx106-elf/bin"; do
    check_path "$path"
done

echo
echo '== Current config files =='
for path in \
    "$HOME/.bash_it" \
    "$HOME/.shell-config/modules/env/machine_local.sh" \
    "$HOME/.shell-config/modules/env/machine-local.example.sh"; do
    check_path "$path"
done

echo
echo 'Preflight check completed.'