ATUIN_BIN_DIR="$HOME/.atuin/bin"
ATUIN_ENV_FILE="$ATUIN_BIN_DIR/env"
ATUIN_INIT_GUARD_VAR="${ATUIN_INIT_GUARD_VAR:-__SHELL_CONFIG_ATUIN_INITIALIZED}"

if [[ -f "$ATUIN_ENV_FILE" ]]; then
	# shellcheck source=/dev/null
	. "$ATUIN_ENV_FILE"
elif [[ -d "$ATUIN_BIN_DIR" && ":$PATH:" != *":$ATUIN_BIN_DIR:"* ]]; then
	export PATH="$ATUIN_BIN_DIR:$PATH"
fi

if command -v atuin >/dev/null 2>&1; then
	if [[ "${!ATUIN_INIT_GUARD_VAR:-0}" != "1" ]]; then
		[[ -f "$HOME/.bash-preexec.sh" ]] && source "$HOME/.bash-preexec.sh"
		eval "$(atuin init bash)"
		printf -v "$ATUIN_INIT_GUARD_VAR" '%s' "1"
	fi
fi
