#!/bin/bash

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

function _nvm_init() {
	if [[ "${__NVM_LAZY_LOADED:-false}" == "true" ]]; then
		return 0
	fi

	if [[ -s "$NVM_DIR/nvm.sh" ]]; then
		# shellcheck source=/dev/null
		. "$NVM_DIR/nvm.sh"
	else
		return 1
	fi

	if [[ -s "$NVM_DIR/bash_completion" ]]; then
		# shellcheck source=/dev/null
		. "$NVM_DIR/bash_completion"
	fi

	__NVM_LAZY_LOADED=true
}

function _nvm_warn_system_fallback() {
	local cmd_name="$1"
	local resolved_cmd

	if [[ "${__NVM_SYSTEM_FALLBACK_WARNED:-false}" == "true" ]]; then
		return
	fi

	resolved_cmd="$(command -v "$cmd_name" 2> /dev/null || true)"
	printf 'shell-config: NVM is not available at %s, falling back to system %s' "$NVM_DIR" "$cmd_name" >&2
	if [[ -n "$resolved_cmd" ]]; then
		printf ' (%s)' "$resolved_cmd" >&2
	fi
	printf '.\n' >&2
	__NVM_SYSTEM_FALLBACK_WARNED=true
}

function _nvm_warn_global_prefix() {
	local npm_prefix
	local arg

	for arg in "$@"; do
		if [[ "$arg" == "-g" || "$arg" == "--global" ]]; then
			npm_prefix="$(command npm config get prefix 2> /dev/null || true)"
			if [[ "$npm_prefix" == "/usr" || "$npm_prefix" == "/usr/local" || "$npm_prefix" == /usr/* || "$npm_prefix" == /usr/local/* ]]; then
				printf 'shell-config: system npm global prefix is %s, global installs may require elevated permissions.\n' "$npm_prefix" >&2
			fi
			return
		fi
	done
}

function _nvm_run_command() {
	local cmd_name="$1"
	shift

	if _nvm_init; then
		unset -f node npm nvm
		command "$cmd_name" "$@"
		return
	fi

	if [[ "$cmd_name" != "nvm" ]] && command -v "$cmd_name" > /dev/null 2>&1; then
		_nvm_warn_system_fallback "$cmd_name"
		if [[ "$cmd_name" == "npm" ]]; then
			_nvm_warn_global_prefix "$@"
		fi
		unset -f node npm
		command "$cmd_name" "$@"
		return
	fi

	printf 'shell-config: NVM is not available at %s\n' "$NVM_DIR" >&2
	printf 'shell-config: install NVM or set NVM_DIR correctly.\n' >&2
	return 127
}

function node() {
	_nvm_run_command node "$@"
}

function npm() {
	_nvm_run_command npm "$@"
}

function nvm() {
	_nvm_run_command nvm "$@"
}