#!/bin/bash
set -e

COLOR_RESET='\033[0m'
COLOR_INFO='\033[36m'
COLOR_WARN='\033[33m'
COLOR_SUCCESS='\033[32m'

log_with_level() {
    local level="$1"
    local color="$2"
    shift 2

    printf '[%b%s%b] %b%s%b\n' "$color" "$level" "$COLOR_RESET" "$color" "$*" "$COLOR_RESET"
}

log_info() {
    log_with_level INFO "$COLOR_INFO" "$@"
}

log_warn() {
    log_with_level WARN "$COLOR_WARN" "$@"
}

log_success() {
    log_with_level OK "$COLOR_SUCCESS" "$@"
}

print_section() {
    local title="$1"
    printf '%b== %s ==%b\n' "$COLOR_INFO" "$title" "$COLOR_RESET"
}

check_command() {
    local name="$1"

    if command -v "$name" >/dev/null 2>&1; then
        log_success "command: $name"
    else
        log_warn "missing command: $name"
    fi
}

check_path() {
    local path="$1"

    if [[ -e "$path" ]]; then
        log_success "path: $path"
    else
        log_warn "missing path: $path"
    fi
}

print_section 'Required commands'
for cmd in bash git curl grep awk; do
    check_command "$cmd"
done

echo
print_section 'Recommended commands'
for cmd in rsync dircolors tput; do
    check_command "$cmd"
done

echo
print_section 'Auto-installed tools'
for cmd in atuin; do
    if command -v "$cmd" >/dev/null 2>&1; then
        log_success "command: $cmd"
    else
        log_info "will be installed by install.sh: $cmd"
    fi
done

echo
print_section 'Optional tools'
for cmd in autojump ipmitool python3; do
    check_command "$cmd"
done

echo
print_section 'Expected user paths'
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
print_section 'Current config files'
for path in \
    "$HOME/.bash_it" \
    "$HOME/.shell-config/modules/env/machine_local.sh" \
    "$HOME/.shell-config/modules/env/machine-local.example.sh"; do
    check_path "$path"
done

echo
log_success 'Preflight check completed.'