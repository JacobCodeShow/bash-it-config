#!/bin/bash
set -e

BASH_IT_DIR="${BASH_IT_DIR:-$HOME/.bash_it}"
CFG_DIR="${SHELL_CONFIG_DIR:-$HOME/.shell-config}"
REMOVE_FRAMEWORK=0
BASH_IT_BOOTSTRAP_BEGIN="# shell-config bash-it bootstrap begin"
BASH_IT_BOOTSTRAP_END="# shell-config bash-it bootstrap end"

ALIASES=(
    "shell-config.aliases.bash"
)

PLUGINS=(
    "shell-config.atuin.plugin.bash"
    "shell-config.completion.plugin.bash"
    "shell-config.ci.plugin.bash"
    "shell-config.nvm.plugin.bash"
    "shell-config.terminal.plugin.bash"
)

CUSTOMS=(
    "shell-config.env.bash"
    "shell-config.path.bash"
)

for arg in "$@"; do
    case "$arg" in
        --remove-framework)
            REMOVE_FRAMEWORK=1
        ;;
        *)
            echo "Unknown argument: $arg"
            echo "Supported arguments: --remove-framework"
            exit 1
        ;;
    esac
done

for file_name in "${ALIASES[@]}"; do
    rm -f "$BASH_IT_DIR/aliases/enabled/$file_name"
    rm -f "$BASH_IT_DIR/aliases/available/$file_name"
done

for file_name in "${PLUGINS[@]}"; do
    rm -f "$BASH_IT_DIR/plugins/enabled/$file_name"
    rm -f "$BASH_IT_DIR/plugins/available/$file_name"
done

for file_name in "${CUSTOMS[@]}"; do
    rm -f "$BASH_IT_DIR/custom/$file_name"
done

remove_bashrc_bootstrap() {
    local bashrc="$HOME/.bashrc"

    if [[ ! -f "$bashrc" ]]; then
        return
    fi

    if grep -qF "$BASH_IT_BOOTSTRAP_BEGIN" "$bashrc"; then
        sed -i "/$(printf '%s' "$BASH_IT_BOOTSTRAP_BEGIN" | sed 's/[.[\*^$()+?{|]/\\&/g')/,/$(printf '%s' "$BASH_IT_BOOTSTRAP_END" | sed 's/[.[\*^$()+?{|]/\\&/g')/d" "$bashrc"
        echo "Removed shell-config bash-it bootstrap block from $bashrc"
        return
    fi

    sed -i '/^# shell-config bootstrap for bash-it$/,/^source "\${BASH_IT?}\/bash_it\.sh"$/d' "$bashrc"
}

rm -rf "$BASH_IT_DIR/themes/bobby-jacob"

if [[ -d "$CFG_DIR" ]]; then
    rm -rf "$CFG_DIR"
    echo "Removed $CFG_DIR"
fi

if [[ "$REMOVE_FRAMEWORK" -eq 1 && -d "$BASH_IT_DIR" ]]; then
    rm -rf "$BASH_IT_DIR"
    remove_bashrc_bootstrap
    echo "Removed $BASH_IT_DIR"
fi

echo "shell-config uninstall completed."
if [[ "$REMOVE_FRAMEWORK" -eq 1 ]]; then
    echo "Removed shell-config bootstrap from ~/.bashrc when present."
else
    echo "Current ~/.bashrc is unchanged."
fi