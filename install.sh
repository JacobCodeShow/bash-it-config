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
mkdir -p "$TARGET_CFG_DIR"
mkdir -p "$HOME/.local/npm/bin"

CURRENT_FILE="$(readlink -f "$0")"
CURRENT_FILE_DIR="$(dirname "$CURRENT_FILE")"

BASH_IT_DIR="${BASH_IT_DIR:-$HOME/.bash_it}"
BASH_IT_THEME_NAME="bobby-jacob"
BASH_IT_BOOTSTRAPPED=false
BASH_IT_BOOTSTRAP_BEGIN="# shell-config bash-it bootstrap begin"
BASH_IT_BOOTSTRAP_END="# shell-config bash-it bootstrap end"

ensure_bash_it_framework() {
    if [[ -f "$BASH_IT_DIR/bash_it.sh" ]]; then
        return
    fi

    if [[ -d "$BASH_IT_DIR" ]]; then
        if [[ -n "$(ls -A "$BASH_IT_DIR" 2>/dev/null)" ]]; then
            echo "Existing $BASH_IT_DIR does not look like bash-it; aborting auto-bootstrap."
            exit 1
        fi
        rmdir "$BASH_IT_DIR"
    elif [[ -e "$BASH_IT_DIR" ]]; then
        echo "$BASH_IT_DIR exists but is not a directory; aborting auto-bootstrap."
        exit 1
    fi

    echo -e "[\033[32m CMD RUN \033[0m] \033[34m git clone --depth=1 https://github.com/Bash-it/bash-it.git $BASH_IT_DIR \033[0m"
    git clone --depth=1 https://github.com/Bash-it/bash-it.git "$BASH_IT_DIR"
    BASH_IT_BOOTSTRAPPED=true
}

configure_bash_it_theme() {
    local bashrc="$HOME/.bashrc"

    touch "$bashrc"

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
source "\${BASH_IT?}/bash_it.sh"
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

ensure_bash_it_framework

item_list=(
    bobby-jacob
    modules
    README.md
    new-machine-checklist.md
    preflight_check.sh
    install.sh
    uninstall.sh
)

for item_name in "${item_list[@]}"; do
    item_path="$CURRENT_FILE_DIR/$item_name"
    if [[ -e "$item_path" ]];then
        echo -e "[\033[32m CMD RUN \033[0m] \033[34m cp $item_path $TARGET_CFG_DIR -a \033[0m"
        cp -a "$item_path" "$TARGET_CFG_DIR"
    fi
done

rm -f "$TARGET_CFG_DIR/start_my_cfg"
rm -f "$TARGET_CFG_DIR/main_cfg.sh"
rm -f "$TARGET_CFG_DIR/my_PS1_setting"
rm -f "$TARGET_CFG_DIR/my_alias"
rm -f "$TARGET_CFG_DIR/my_export"
rm -f "$TARGET_CFG_DIR/my_path"
rm -f "$TARGET_CFG_DIR/.bashrc_full"
rm -rf "$TARGET_CFG_DIR/core"
rm -rf "$TARGET_CFG_DIR/legacy"
rm -f "$TARGET_CFG_DIR/.bashrc"
mkdir -p "$BASH_IT_DIR/aliases/available" "$BASH_IT_DIR/aliases/enabled"
mkdir -p "$BASH_IT_DIR/plugins/available" "$BASH_IT_DIR/plugins/enabled"
mkdir -p "$BASH_IT_DIR/custom"
mkdir -p "$BASH_IT_DIR/themes"

cat <<'EOF' > "$BASH_IT_DIR/aliases/available/shell-config.aliases.bash"
#!/bin/bash

SHELL_CONFIG_DIR="${SHELL_CONFIG_DIR:-$HOME/.shell-config}"
MAIN_FILE="$SHELL_CONFIG_DIR/modules/aliases.sh"

if [[ -f "$MAIN_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$MAIN_FILE"
fi
EOF

cat <<'EOF' > "$BASH_IT_DIR/plugins/available/shell-config.atuin.plugin.bash"
#!/bin/bash

SHELL_CONFIG_DIR="${SHELL_CONFIG_DIR:-$HOME/.shell-config}"
MAIN_FILE="$SHELL_CONFIG_DIR/modules/tools/tool-atuin.sh"

if [[ -f "$MAIN_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$MAIN_FILE"
fi
EOF

cat <<'EOF' > "$BASH_IT_DIR/plugins/available/shell-config.completion.plugin.bash"
#!/bin/bash

SHELL_CONFIG_DIR="${SHELL_CONFIG_DIR:-$HOME/.shell-config}"

for file in \
    "$SHELL_CONFIG_DIR/modules/completion/completion-local.sh" \
    "$SHELL_CONFIG_DIR/modules/completion/completion-openbmc.sh"; do
    if [[ -f "$file" ]]; then
        # shellcheck source=/dev/null
        source "$file"
    fi
done
EOF

cat <<'EOF' > "$BASH_IT_DIR/plugins/available/shell-config.ci.plugin.bash"
#!/bin/bash

SHELL_CONFIG_DIR="${SHELL_CONFIG_DIR:-$HOME/.shell-config}"
MAIN_FILE="$SHELL_CONFIG_DIR/modules/tools/tool-openbmc-ci.sh"

if [[ -f "$MAIN_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$MAIN_FILE"
fi
EOF

cat <<'EOF' > "$BASH_IT_DIR/plugins/available/shell-config.nvm.plugin.bash"
#!/bin/bash

SHELL_CONFIG_DIR="${SHELL_CONFIG_DIR:-$HOME/.shell-config}"
MAIN_FILE="$SHELL_CONFIG_DIR/modules/tools/tool-nvm.sh"

if [[ -f "$MAIN_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$MAIN_FILE"
fi
EOF

cat <<'EOF' > "$BASH_IT_DIR/plugins/available/shell-config.terminal.plugin.bash"
#!/bin/bash

SHELL_CONFIG_DIR="${SHELL_CONFIG_DIR:-$HOME/.shell-config}"
MAIN_FILE="$SHELL_CONFIG_DIR/modules/terminal/terminal-settings.sh"

if [[ -f "$MAIN_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$MAIN_FILE"
fi
EOF

cat <<'EOF' > "$BASH_IT_DIR/custom/shell-config.env.bash"
#!/bin/bash

SHELL_CONFIG_DIR="${SHELL_CONFIG_DIR:-$HOME/.shell-config}"

for file in \
    "$SHELL_CONFIG_DIR/modules/env/env-locale.sh" \
    "$SHELL_CONFIG_DIR/modules/env/env-vars.sh" \
    "$SHELL_CONFIG_DIR/modules/env/machine_local.sh"; do
    if [[ -f "$file" ]]; then
        # shellcheck source=/dev/null
        source "$file"
    fi
done
EOF

cat <<'EOF' > "$BASH_IT_DIR/custom/shell-config.path.bash"
#!/bin/bash

SHELL_CONFIG_DIR="${SHELL_CONFIG_DIR:-$HOME/.shell-config}"
MAIN_FILE="$SHELL_CONFIG_DIR/modules/env/env-path.sh"

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

if [[ "$BASH_IT_BOOTSTRAPPED" == "true" ]]; then
    configure_bash_it_theme
fi

echo "Synchronized config into $TARGET_CFG_DIR"
echo "Imported shell-config files into ${BASH_IT_DIR}"
echo "Installed bash-it theme: bobby-jacob"
if [[ "$BASH_IT_BOOTSTRAPPED" == "true" ]]; then
    echo "Bootstrapped bash-it into ${BASH_IT_DIR} and configured ~/.bashrc theme: ${BASH_IT_THEME_NAME}"
else
    echo "Current ~/.bashrc and existing bash-it startup chain are unchanged"
fi


