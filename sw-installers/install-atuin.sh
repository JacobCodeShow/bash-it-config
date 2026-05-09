#!/bin/bash
set -euo pipefail

ATUIN_INSTALLER_URL="https://github.com/atuinsh/atuin/releases/latest/download/atuin-installer.sh"
BASH_PREEXEC_URL="https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh"
ATUIN_MANAGED_BIN="$HOME/.atuin/bin/atuin"
BASH_PREEXEC_FILE="$HOME/.bash-preexec.sh"

COLOR_RESET='\033[0m'
COLOR_INFO='\033[36m'
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

log_error() {
	log_with_level ERROR "$COLOR_ERROR" "$@"
}

log_success() {
	log_with_level OK "$COLOR_SUCCESS" "$@"
}

log_command() {
	printf '[%bCMD RUN%b] %b%s%b\n' "$COLOR_SUCCESS" "$COLOR_RESET" "$COLOR_CMD" "$*" "$COLOR_RESET"
}

require_command() {
	local cmd_name="$1"

	if ! command -v "$cmd_name" >/dev/null 2>&1; then
		log_error "Missing required command: $cmd_name"
		exit 1
	fi
}

install_atuin_binary() {
	if [[ -x "$ATUIN_MANAGED_BIN" ]]; then
		log_info "Atuin already installed at $ATUIN_MANAGED_BIN"
		return
	fi

	if command -v atuin >/dev/null 2>&1; then
		log_info "Atuin already available at $(command -v atuin); skipping managed install."
		return
	fi

	require_command curl
	log_command "curl --proto '=https' --tlsv1.2 -LsSf $ATUIN_INSTALLER_URL | ATUIN_NO_MODIFY_PATH=1 sh"
	curl --proto '=https' --tlsv1.2 -LsSf "$ATUIN_INSTALLER_URL" | ATUIN_NO_MODIFY_PATH=1 sh

	if [[ ! -x "$ATUIN_MANAGED_BIN" ]] && ! command -v atuin >/dev/null 2>&1; then
		log_error "Atuin install completed without producing a usable atuin binary."
		exit 1
	fi

	log_success "Atuin binary is ready."
}

ensure_bash_preexec() {
	if [[ -f "$BASH_PREEXEC_FILE" ]]; then
		return
	fi

	require_command curl
	log_command "curl --proto '=https' --tlsv1.2 -LsSf $BASH_PREEXEC_URL -o $BASH_PREEXEC_FILE"
	curl --proto '=https' --tlsv1.2 -LsSf "$BASH_PREEXEC_URL" -o "$BASH_PREEXEC_FILE"
	log_success "Installed bash-preexec at $BASH_PREEXEC_FILE"
}

install_atuin_binary
ensure_bash_preexec