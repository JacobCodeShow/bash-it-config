#!/bin/bash
set -e

echo "
-------------------------------------------------------------------------------------------------------------------------
  __  __  __     __     _____   _    _   ______   _        _           _____    ____    _   _   ______   _____    _____ 
 |  \/  | \ \   / /    / ____| | |  | | |  ____| | |      | |         / ____|  / __ \  | \ | | |  ____| |_   _|  / ____|
 | \  / |  \ \_/ /    | (___   | |__| | | |__    | |      | |        | |      | |  | | |  \| | | |__      | |   | |  __ 
 | |\/| |   \   /      \___ \  |  __  | |  __|   | |      | |        | |      | |  | | | . \` | |  __|     | |   | | |_ |
 | |  | |    | |       ____) | | |  | | | |____  | |____  | |____    | |____  | |__| | | |\  | | |       _| |_  | |__| |
 |_|  |_|    |_|      |_____/  |_|  |_| |______| |______| |______|    \_____|  \____/  |_| \_| |_|      |_____|  \_____|
                                                                                                                         
--------------------------------------------------------------------------------------------------------------------------
"

TARGET_CFG_DIR="$HOME/.shell-config"

CURRENT_FILE="$(readlink -f "$0")"
CURRENT_FILE_DIR="$(dirname "$CURRENT_FILE")"

BASH_IT_DIR="${BASH_IT_DIR:-$HOME/.bash_it}"
BASH_IT_THEME_NAME="bobby-jacob"
BASH_IT_BOOTSTRAPPED=false
BASH_IT_BOOTSTRAP_BEGIN="# shell-config bash-it bootstrap begin"
BASH_IT_BOOTSTRAP_END="# shell-config bash-it bootstrap end"
FORCE_INSTALL=false
INSTALLER_DIR_PATH=""
INSTALLER_DIR_NAME=""

COLOR_RESET='\033[0m'
COLOR_INFO='\033[36m'
COLOR_WARN='\033[33m'
COLOR_ERROR='\033[31m'
COLOR_SUCCESS='\033[32m'
COLOR_CMD='\033[34m'

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

log_error() {
    log_with_level ERROR "$COLOR_ERROR" "$@"
}

log_success() {
    log_with_level OK "$COLOR_SUCCESS" "$@"
}

log_cmd() {
    printf '[%bCMD RUN%b] %b%s%b\n' "$COLOR_SUCCESS" "$COLOR_RESET" "$COLOR_CMD" "$*" "$COLOR_RESET"
}

resolve_installer_dir() {
    local candidate_dir
    local install_scripts=()

    if [[ -d "$CURRENT_FILE_DIR/sw-installers" ]]; then
        INSTALLER_DIR_PATH="$CURRENT_FILE_DIR/sw-installers"
        INSTALLER_DIR_NAME="sw-installers"
        return
    fi

    shopt -s nullglob
    for candidate_dir in "$CURRENT_FILE_DIR"/*; do
        [[ -d "$candidate_dir" ]] || continue
        install_scripts=("$candidate_dir"/install-*.sh)
        if (( ${#install_scripts[@]} > 0 )); then
            INSTALLER_DIR_PATH="$candidate_dir"
            INSTALLER_DIR_NAME="$(basename "$candidate_dir")"
            shopt -u nullglob
            return
        fi
    done
    shopt -u nullglob
}

usage() {
    cat <<EOF
Usage: ./install.sh [options]

Options:
  -f, --force    Skip the confirmation prompt and continue installation after preflight.
  -h, --help     Show this help message.
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -f|--force)
                FORCE_INSTALL=true
            ;;
            -h|--help)
                usage
                exit 0
            ;;
            *)
                log_error "Unknown argument: $1"
                usage
                exit 1
            ;;
        esac
        shift
    done
}

run_preflight_check() {
    local preflight_script="$CURRENT_FILE_DIR/preflight_check.sh"

    if [[ ! -f "$preflight_script" ]]; then
        log_error "Missing preflight script: $preflight_script"
        exit 1
    fi

    log_cmd "bash $preflight_script"
    if bash "$preflight_script"; then
        return
    fi

    if [[ "$FORCE_INSTALL" == "true" ]]; then
        log_warn "Preflight check exited with errors, but continuing because --force was specified."
        return
    fi

    log_error "Preflight check failed. Please update your configuration and rerun install.sh, or use -f/--force to continue."
    exit 1
}

confirm_installation() {
    local answer=""

    if [[ "$FORCE_INSTALL" == "true" ]]; then
        log_warn "Force mode enabled. Skipping confirmation and continuing installation."
        return
    fi

    echo
    printf '%b[CONFIRM]%b Preflight completed. Continue installation? [y/N] ' "$COLOR_INFO" "$COLOR_RESET"
    if ! IFS= read -r answer; then
        echo
        log_warn "Installation aborted. Please update your configuration as needed and rerun install.sh."
        exit 1
    fi

    case "$answer" in
        [yY]|[yY][eE][sS])
            log_info "Continuing installation."
            return
        ;;
        *)
            log_warn "Installation aborted. Please update your configuration as needed and rerun install.sh."
            exit 1
        ;;
    esac
}

ensure_bash_it_framework() {
    if [[ -f "$BASH_IT_DIR/bash_it.sh" ]]; then
        return
    fi

    if [[ -d "$BASH_IT_DIR" ]]; then
        if [[ -n "$(ls -A "$BASH_IT_DIR" 2>/dev/null)" ]]; then
            log_error "Existing $BASH_IT_DIR does not look like bash-it; aborting auto-bootstrap."
            exit 1
        fi
        rmdir "$BASH_IT_DIR"
    elif [[ -e "$BASH_IT_DIR" ]]; then
        log_error "$BASH_IT_DIR exists but is not a directory; aborting auto-bootstrap."
        exit 1
    fi

    log_cmd "git clone --depth=1 https://github.com/Bash-it/bash-it.git $BASH_IT_DIR"
    git clone --depth=1 https://github.com/Bash-it/bash-it.git "$BASH_IT_DIR"
    BASH_IT_BOOTSTRAPPED=true
}

patch_bash_it_alias_completion() {
    local completion_file="$BASH_IT_DIR/completion/available/aliases.completion.bash"
    local tmp_file=""

    if [[ ! -f "$completion_file" ]]; then
        return
    fi

    if grep -q "Single quotes inside alias definitions can break generated wrapper quoting" "$completion_file"; then
        return
    fi

    tmp_file="$(mktemp)"
    awk '
        /# avoid expanding wildcards/ && !inserted {
            print ""
            print "\t\t# Single quotes inside alias definitions can break generated wrapper quoting."
            print "\t\t# Skip auto-completion wrapper generation for those aliases."
            print "\t\tif [[ \"$alias_defn\" == *\"\x27\"* ]]; then"
            print "\t\t\tcontinue"
            print "\t\tfi"
            inserted=1
        }
        { print }
    ' "$completion_file" > "$tmp_file"
    mv "$tmp_file" "$completion_file"
}

configure_bash_it_theme() {
    local bashrc="$HOME/.bashrc"

    touch "$bashrc"

    if [[ "$BASH_IT_BOOTSTRAPPED" != "true" ]]; then
        if grep -q '^export BASH_IT_THEME=' "$bashrc"; then
            sed -i "s|^export BASH_IT_THEME=.*$|export BASH_IT_THEME='$BASH_IT_THEME_NAME'|" "$bashrc"
            return 0
        fi

        if grep -q '^export BASH_IT=' "$bashrc"; then
            sed -i "/^export BASH_IT=/a export BASH_IT_THEME='$BASH_IT_THEME_NAME'" "$bashrc"
            return 0
        fi

        if grep -q 'bash_it\.sh' "$bashrc"; then
            sed -i "/bash_it\\.sh/i export BASH_IT_THEME='$BASH_IT_THEME_NAME'" "$bashrc"
            return 0
        fi

        return 1
    fi

    if grep -qF "$BASH_IT_BOOTSTRAP_BEGIN" "$bashrc"; then
        sed -i "/$(printf '%s' "$BASH_IT_BOOTSTRAP_BEGIN" | sed 's/[.[\*^$()+?{|]/\\&/g')/,/$(printf '%s' "$BASH_IT_BOOTSTRAP_END" | sed 's/[.[\*^$()+?{|]/\\&/g')/d" "$bashrc"
    fi

    if grep -q '^export BASH_IT=' "$bashrc"; then
        sed -i "s|^export BASH_IT=.*$|export BASH_IT=\"$BASH_IT_DIR\"|" "$bashrc"
    fi

    if grep -q '^export BASH_IT_THEME=' "$bashrc"; then
        sed -i "s|^export BASH_IT_THEME=.*$|export BASH_IT_THEME='$BASH_IT_THEME_NAME'|" "$bashrc"
    fi

    if ! grep -q 'bash_it\.sh' "$bashrc"; then
        cat <<EOF >> "$bashrc"

$BASH_IT_BOOTSTRAP_BEGIN
export BASH_IT="$BASH_IT_DIR"
export BASH_IT_THEME='$BASH_IT_THEME_NAME'
if [[ "${SHELL_CONFIG_BASH_IT_SESSION_PID:-}" != "$$" || "${SHELL_CONFIG_FORCE_BASH_IT_RELOAD:-0}" == "1" || "$(type -t x 2>/dev/null || true)" != "function" ]]; then
    SHELL_CONFIG_BASH_IT_SESSION_PID=$$
    source "\${BASH_IT?}/bash_it.sh"
fi
$BASH_IT_BOOTSTRAP_END
EOF
        return
    fi

    if ! grep -q '^export BASH_IT=' "$bashrc"; then
        sed -i "/bash_it\\.sh/i export BASH_IT=\"$BASH_IT_DIR\"" "$bashrc"
    fi

    if ! grep -q '^export BASH_IT_THEME=' "$bashrc"; then
        sed -i "/^export BASH_IT=/a export BASH_IT_THEME='$BASH_IT_THEME_NAME'" "$bashrc"
    fi
}

run_setup_script() {
    local script_path="$1"

    if [[ ! -f "$script_path" ]]; then
        return
    fi

    log_cmd "bash $script_path"
    bash "$script_path"
}

parse_args "$@"
resolve_installer_dir

ensure_bash_it_framework
patch_bash_it_alias_completion

run_preflight_check
confirm_installation

mkdir -p "$TARGET_CFG_DIR"
mkdir -p "$HOME/.local/npm/bin"

item_list=(
    bobby-jacob
    modules
    README.md
    new-machine-checklist.md
    preflight_check.sh
    install.sh
    uninstall.sh
)

if [[ -n "$INSTALLER_DIR_NAME" ]]; then
    item_list+=("$INSTALLER_DIR_NAME")
fi

for item_name in "${item_list[@]}"; do
    item_path="$CURRENT_FILE_DIR/$item_name"
    if [[ -e "$item_path" ]];then
        log_cmd "cp $item_path $TARGET_CFG_DIR -a"
        cp -a "$item_path" "$TARGET_CFG_DIR"
    fi
done

if [[ -n "$INSTALLER_DIR_PATH" ]]; then
    shopt -s nullglob
    for setup_script in "$INSTALLER_DIR_PATH"/install-*.sh; do
        run_setup_script "$setup_script"
    done
    shopt -u nullglob
else
    log_warn "No software installer directory was found under $CURRENT_FILE_DIR; skipping managed tool installers."
fi

rm -f "$TARGET_CFG_DIR/start_my_cfg"
rm -f "$TARGET_CFG_DIR/main_cfg.sh"
rm -f "$TARGET_CFG_DIR/my_PS1_setting"
rm -f "$TARGET_CFG_DIR/my_alias"
rm -f "$TARGET_CFG_DIR/my_export"
rm -f "$TARGET_CFG_DIR/my_path"
rm -f "$TARGET_CFG_DIR/.bashrc_full"
rm -rf "$TARGET_CFG_DIR/installers"
rm -f "$TARGET_CFG_DIR/modules/tools/install-atuin.sh"
rm -rf "$TARGET_CFG_DIR/core"
rm -rf "$TARGET_CFG_DIR/legacy"
rm -f "$TARGET_CFG_DIR/.bashrc"
mkdir -p "$BASH_IT_DIR/aliases/available" "$BASH_IT_DIR/aliases/enabled"
mkdir -p "$BASH_IT_DIR/plugins/available" "$BASH_IT_DIR/plugins/enabled"
mkdir -p "$BASH_IT_DIR/custom"
mkdir -p "$BASH_IT_DIR/themes"

cat <<'EOF' > "$BASH_IT_DIR/aliases/available/shell-config.aliases.bash"
#!/bin/bash

SHELL_CONFIG_RUNTIME_DIR="${SHELL_CONFIG_RUNTIME_DIR:-$HOME/.shell-config}"
MAIN_FILE="$SHELL_CONFIG_RUNTIME_DIR/modules/aliases.sh"

if [[ -f "$MAIN_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$MAIN_FILE"
fi
EOF

cat <<'EOF' > "$BASH_IT_DIR/plugins/available/shell-config.atuin.plugin.bash"
#!/bin/bash

SHELL_CONFIG_RUNTIME_DIR="${SHELL_CONFIG_RUNTIME_DIR:-$HOME/.shell-config}"
MAIN_FILE="$SHELL_CONFIG_RUNTIME_DIR/modules/tools/tool-atuin.sh"

if [[ -f "$MAIN_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$MAIN_FILE"
fi
EOF

cat <<'EOF' > "$BASH_IT_DIR/plugins/available/shell-config.completion.plugin.bash"
#!/bin/bash

SHELL_CONFIG_RUNTIME_DIR="${SHELL_CONFIG_RUNTIME_DIR:-$HOME/.shell-config}"

for file in \
    "$SHELL_CONFIG_RUNTIME_DIR/modules/completion/completion-local.sh" \
    "$SHELL_CONFIG_RUNTIME_DIR/modules/completion/completion-openbmc.sh"; do
    if [[ -f "$file" ]]; then
        # shellcheck source=/dev/null
        source "$file"
    fi
done
EOF

cat <<'EOF' > "$BASH_IT_DIR/plugins/available/shell-config.ci.plugin.bash"
#!/bin/bash

SHELL_CONFIG_RUNTIME_DIR="${SHELL_CONFIG_RUNTIME_DIR:-$HOME/.shell-config}"
MAIN_FILE="$SHELL_CONFIG_RUNTIME_DIR/modules/tools/tool-openbmc-ci.sh"

if [[ -f "$MAIN_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$MAIN_FILE"
fi
EOF

cat <<'EOF' > "$BASH_IT_DIR/plugins/available/shell-config.nvm.plugin.bash"
#!/bin/bash

SHELL_CONFIG_RUNTIME_DIR="${SHELL_CONFIG_RUNTIME_DIR:-$HOME/.shell-config}"
MAIN_FILE="$SHELL_CONFIG_RUNTIME_DIR/modules/tools/tool-nvm.sh"

if [[ -f "$MAIN_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$MAIN_FILE"
fi
EOF

cat <<'EOF' > "$BASH_IT_DIR/plugins/available/shell-config.terminal.plugin.bash"
#!/bin/bash

SHELL_CONFIG_RUNTIME_DIR="${SHELL_CONFIG_RUNTIME_DIR:-$HOME/.shell-config}"
MAIN_FILE="$SHELL_CONFIG_RUNTIME_DIR/modules/terminal/terminal-settings.sh"

if [[ -f "$MAIN_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$MAIN_FILE"
fi
EOF

cat <<'EOF' > "$BASH_IT_DIR/custom/shell-config.env.bash"
#!/bin/bash

SHELL_CONFIG_RUNTIME_DIR="${SHELL_CONFIG_RUNTIME_DIR:-$HOME/.shell-config}"

for file in \
    "$SHELL_CONFIG_RUNTIME_DIR/modules/env/env-locale.sh" \
    "$SHELL_CONFIG_RUNTIME_DIR/modules/env/env-vars.sh" \
    "$SHELL_CONFIG_RUNTIME_DIR/modules/env/machine_local.sh"; do
    if [[ -f "$file" ]]; then
        # shellcheck source=/dev/null
        source "$file"
    fi
done
EOF

cat <<'EOF' > "$BASH_IT_DIR/custom/shell-config.path.bash"
#!/bin/bash

SHELL_CONFIG_RUNTIME_DIR="${SHELL_CONFIG_RUNTIME_DIR:-$HOME/.shell-config}"
MAIN_FILE="$SHELL_CONFIG_RUNTIME_DIR/modules/env/env-path.sh"

if [[ -f "$MAIN_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$MAIN_FILE"
fi
EOF

rm -f "$BASH_IT_DIR/custom/shell-config.prompt.bash"
rm -rf "$BASH_IT_DIR/themes/bobby-jacob"
cp -a "$TARGET_CFG_DIR/bobby-jacob" "$BASH_IT_DIR/themes/"

ln -sfn "$BASH_IT_DIR/aliases/available/shell-config.aliases.bash" "$BASH_IT_DIR/aliases/enabled/shell-config.aliases.bash"
ln -sfn "$BASH_IT_DIR/plugins/available/shell-config.atuin.plugin.bash" "$BASH_IT_DIR/plugins/enabled/shell-config.atuin.plugin.bash"
ln -sfn "$BASH_IT_DIR/plugins/available/shell-config.completion.plugin.bash" "$BASH_IT_DIR/plugins/enabled/shell-config.completion.plugin.bash"
ln -sfn "$BASH_IT_DIR/plugins/available/shell-config.ci.plugin.bash" "$BASH_IT_DIR/plugins/enabled/shell-config.ci.plugin.bash"
ln -sfn "$BASH_IT_DIR/plugins/available/shell-config.nvm.plugin.bash" "$BASH_IT_DIR/plugins/enabled/shell-config.nvm.plugin.bash"
ln -sfn "$BASH_IT_DIR/plugins/available/shell-config.terminal.plugin.bash" "$BASH_IT_DIR/plugins/enabled/shell-config.terminal.plugin.bash"

if configure_bash_it_theme; then
    log_success "Configured ~/.bashrc theme: ${BASH_IT_THEME_NAME}"
else
    log_warn "Installed theme files, but could not locate bash-it startup config in ~/.bashrc to update BASH_IT_THEME automatically"
fi

log_success "Synchronized config into $TARGET_CFG_DIR"
log_success "Imported shell-config files into ${BASH_IT_DIR}"
log_success "Installed bash-it theme: bobby-jacob"
log_success "Ensured managed tool setup scripts completed"
if [[ "$BASH_IT_BOOTSTRAPPED" == "true" ]]; then
    log_success "Bootstrapped bash-it into ${BASH_IT_DIR} and refreshed ~/.bashrc"
else
    log_info "Preserved the current bash-it startup chain and only updated the theme setting"
fi


