# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

SCM_GIT_SHOW_MINIMAL_INFO=true
SCM_GIT_SHOW_DETAILS=false
SCM_GIT_SHOW_REMOTE_INFO=false
SCM_GIT_SHOW_CURRENT_USER=false

SCM_THEME_PROMPT_DIRTY=" ${red?}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green?}✓"
SCM_THEME_PROMPT_PREFIX=" ${green?}|"
SCM_THEME_PROMPT_SUFFIX="${green?}|"

GIT_THEME_PROMPT_DIRTY=" ${red?}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green?}✓"
GIT_THEME_PROMPT_PREFIX=" ${green?}|"
GIT_THEME_PROMPT_SUFFIX="${green?}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function __bobby_append_clock() {
	local formatted_time

	printf -v formatted_time "%(${THEME_CLOCK_FORMAT})T" -1
	PS1+="${THEME_CLOCK_COLOR}${formatted_time}${reset_color?} "

	if [[ "${THEME_SHOW_CLOCK_CHAR:-}" == "true" ]]; then
		PS1+="${THEME_CLOCK_CHAR_COLOR}${THEME_CLOCK_CHAR}${reset_color?} "
	fi
}

function __bobby_scm_cache_key() {
	local repo_root

	repo_root="$(_bash-it-find-in-ancestor '.git' 2> /dev/null || true)"
	printf '%s' "${repo_root:-$PWD}"
}

function __bobby_refresh_git_cache() {
	local branch
	local git_status

	branch="$(_git-friendly-ref 2> /dev/null || true)"
	if [[ -z "$branch" ]]; then
		__BOBBY_SCM_IS_GIT=false
		return 1
	fi

	__BOBBY_SCM_IS_GIT=true
	__BOBBY_SCM_BRANCH="${branch//\\/\\\\}"
	__BOBBY_SCM_IS_DIRTY=false

	if ! _git-hide-status; then
		git_status="$(_git-status)"
		if [[ -n "$git_status" ]]; then
			__BOBBY_SCM_IS_DIRTY=true
		fi
	fi
}

function __bobby_append_scm() {
	local now
	local cache_ttl="${THEME_SCM_CACHE_SECONDS:-1}"
	local cache_key

	cache_key="$(__bobby_scm_cache_key)"

	if [[ "$cache_ttl" =~ ^[0-9]+$ ]] && (( cache_ttl > 0 )); then
		printf -v now '%(%s)T' -1
		if [[ "${__BOBBY_SCM_CACHE_KEY:-}" != "$cache_key" ]] || [[ -z "${__BOBBY_SCM_CACHE_TS:-}" ]] || (( now - __BOBBY_SCM_CACHE_TS >= cache_ttl )); then
			__BOBBY_SCM_CACHE_KEY="$cache_key"
			__BOBBY_SCM_CACHE_TS="$now"
			if [[ "${SCM_CHECK:-true}" != "false" ]] && [[ -x "${GIT_EXE-}" ]] && _bash-it-find-in-ancestor '.git' > /dev/null 2>&1; then
				__bobby_refresh_git_cache || true
			else
				__BOBBY_SCM_IS_GIT=false
			fi
		fi
	else
		if [[ "${SCM_CHECK:-true}" != "false" ]] && [[ -x "${GIT_EXE-}" ]] && _bash-it-find-in-ancestor '.git' > /dev/null 2>&1; then
			__bobby_refresh_git_cache || true
		else
			__BOBBY_SCM_IS_GIT=false
		fi
	fi

	if [[ "${__BOBBY_SCM_IS_GIT:-false}" == "true" ]]; then
		PS1+="${bold_cyan?}${SCM_GIT_CHAR?}"
		PS1+="${green?}|"
		PS1+="${bold_cyan?}${__BOBBY_SCM_BRANCH:-}"
		if [[ "${__BOBBY_SCM_IS_DIRTY:-false}" == "true" ]]; then
			PS1+=" ${red?}✗"
		else
			PS1+=" ${bold_green?}✓"
		fi
		PS1+="${green?}| "
		return
	fi

	PS1+="${bold_cyan?}$(scm_prompt_char_info) "
}

function prompt_command() {
	PS1=""
	__bobby_append_clock
	# PS1+="${yellow?}$(ruby_version_prompt) "
	PS1+="${blue}(\#) "
	PS1+="${purple?}\u@\h "
	PS1+="${reset_color?}in "
	PS1+="${green?}\W "
	__bobby_append_scm
	PS1+="${green?}→${reset_color?} "
}

: "${THEME_SHOW_CLOCK_CHAR:="false"}"
: "${THEME_CLOCK_CHAR:="◴"}"
: "${THEME_CLOCK_CHAR_COLOR:=${red?}}"
: "${THEME_CLOCK_COLOR:=${bold_cyan?}}"
: "${THEME_CLOCK_FORMAT:="%Y-%m-%d %H:%M:%S"}"
: "${THEME_SCM_CACHE_SECONDS:="1"}"

safe_append_prompt_command prompt_command
