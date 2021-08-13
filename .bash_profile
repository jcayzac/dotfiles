#!/usr/bin/env bash -c /usr/bin/false
set +e +u +o pipefail # continue on errors

[ -z "$BASH_PROFILE_SOURCED" ] || {
	echo >&1 "*** .bash_profile is already sourced."
}

umask 022           # default mode = 755
ulimit -S -n 10240  # raise number of open file handles
shopt -s cmdhist    # save multiline commands in history
shopt -s globstar   # support ** in glob patterns
shopt -s extglob    # extended globs
shopt -s promptvars # expand prompts
tabs -2             # use 2sp-wide tabs

##################
# Base utilities #
##################

# Find if something is a command (better alternative to "which", "type" and others)
#
# $1  Command name
alias has-command='command >/dev/null 2>&1 -v'

# Join an array of strings
#
# $1  Separator
# $2… Strings
join_strings() {
	declare separator="$1"
	declare -a args=("${@:2}")
	declare result
	printf -v result '%s' "${args[@]/#/$separator}"
	printf '%s' "${result:${#separator}}"
}

# Owner of HOME
export LANDLORD=$(id -nu $(stat -f '%u' "$HOME"))

####################
# Base environment #
####################
DEFAULT_LOCALE='en_US.UTF-8'

export \
	ANDROID_SDK_ROOT="$HOME/Library/Android/sdk" \
	ANDROID_NDK_HOME="$HOME/Library/Android/sdk/ndk-bundle" \
	ANT_HOME='/usr/local/opt/ant/libexec' \
	GOPATH="$HOME/.go" \
	GRADLE_HOME='/usr/local/opt/gradle' \
	GREP_COLOR='01' \
	GROOVY_HOME='/usr/local/opt/groovy/libexec' \
	HISTCONTROL='erasedups' \
	HISTFILESIZE=10000 \
	HISTIGNORE='&:ls:cd:pwd:[bf]g:exit:fuck' \
	HOMEBREW_NO_ANALYTICS=1 \
	HOMEBREW_INSTALL_BADGE='  🥃  ' \
	HOMEBREW_INSTALL_CLEANUP=1 \
	JAVA_HOME="$(/usr/libexec/java_home -v 11 2>/dev/null || true)" \
	LANG="$DEFAULT_LOCALE" \
	LC_COLLATE="$DEFAULT_LOCALE" \
	LC_CTYPE="$DEFAULT_LOCALE" \
	LC_MESSAGES="$DEFAULT_LOCALE" \
	LC_MONETARY="$DEFAULT_LOCALE" \
	LC_NUMERIC="$DEFAULT_LOCALE" \
	LC_TIME="$DEFAULT_LOCALE" \
	LC_ALL= \
	LESS_TERMCAP_us=$'\e[01;32m' \
	LESS_TERMCAP_ue=$'\e[0m' \
	LESS_TERMCAP_md=$'\e[01m' \
	LESS_TERMCAP_me=$'\e[0m' \
	LESS='-FXRSN~g' \
	LESSOPEN="|/usr/local/bin/lesspipe.sh %s" \
	LESS_ADVANCED_PREPROCESSOR=1 \
	LS_COLORS='do=01;35:*.dmg=01;31:*.aac=01;35:*.img=01;31:*.tar=01;31:di=01;34:rs=0:*.qt=01;35:ex=01;32:ow=34;42:*.mov=01;35:*.jar=01;31:or=40;31;01:*.pvr=01;35:*.ogm=01;35:*.svgz=01;35:*.toast=01;31:*.asf=01;35:*.bz2=01;31:*.rar=01;31:*.sparsebundle=01;31:*.ogg=01;35:*.m2v=01;35:*.svg=01;35:*.sparseimage=01;31:*.7z=01;31:*.mp4=01;35:*.tbz2=01;31:bd=40;33;01:*.vob=01;35:*.zip=01;31:*.avi=01;35:*.mp3=01;35:so=01;35:*.m4a=01;35:ln=01;36:*.tgz=01;31:tw=30;42:*.png=01;35:*.wmv=01;35:sg=30;43:*.rpm=01;31:*.gz=01;31:*.tbz=01;31:*.mkv=01;35:*.mpg=01;35:*.pkg=01;31:*.mpeg=01;35:*.iso=01;31:ca=30;41:pi=41;33:*.wav=01;35:su=37;41:*.jpg=01;35:st=37;44:cd=40;33;01:*.m4v=01;35:mh=01;36:' \
	MANPATH="$HOME/.prefix/share/man:/usr/local/share/man:/usr/share/man" \
	MAVEN_HOME='/usr/local/opt/maven' \
	PROMPT_DIRTRIM=2 \
	PS1='\[\033[01;34m\]\w\[\033[0m '

# Deprecated, but some tools still rely on it
export ANDROID_HOME="$ANDROID_SDK_ROOT"

PATHS=(
	# User
	"$HOME/.prefix/bin"

	# Go
	"$HOME/.go/bin"
	"/usr/local/opt/go/libexec/bin"

	# Gradle/Maven/Ant/Java
	"$GRADLE_HOME/bin"
	"$MAVEN_HOME/bin"
	"/usr/local/opt/ant/bin"
	"$JAVA_HOME/bin"

	# Android
	"$ANDROID_SDK_ROOT/tools"
	"$ANDROID_SDK_ROOT/tools/bin"
	"$ANDROID_SDK_ROOT/platform-tools"

	# .NET Core SDK
	"/usr/local/share/dotnet"
	"/Library/Frameworks/Mono.framework/Versions/Current/bin"

	# Local
	"/usr/local/bin"
	"/usr/local/sbin"

	# System
	"/usr/bin"
	"/usr/sbin"
	"/bin"
	"/sbin"

	# Relative tools (insecure if not kept last)
	"./node_modules/.bin"
)

export PATH="$(join_strings : ${PATHS[*]})"

! has-command launchctl || {
	launchctl setenv JAVA_HOME "$JAVA_HOME"
}

##################
# Extra builtins #
##################

# Load a builtin from a module
#
# $1   Module name
# $2   Function name
# $3…  (Optional) Exported names. Defauts to function name.
enable-loadable-builtin() {
	declare module="$1"
	shift
	declare args="$@"
	[ -n "$args" ] || args="$module"
	enable -f "/usr/local/opt/bash/lib/bash/$module" $args
}

# Load a bunch of useful builtins at startup
for _ in \
	'basename' \
	'dirname' \
	'finfo' \
	'head' \
	'ln' \
	'mkdir' \
	'mkfifo' \
	'mktemp' \
	'realpath' \
	'rm' \
	'sleep' \
	'strftime' \
	'tee' \
	'truefalse true false' \
	'uname' \
	'unlink' \
	'whoami'; do
	enable-loadable-builtin $_
done
unset -f enable-loadable-builtin

# Export our dotfiles folder
export DOTFILES_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

###########################################################
# Extra libraries of bash functions not loaded at startup #
###########################################################

# Load a library
#
# $1  Library name
load() {
	. "$HOME/.bash.d/on-demand/$1"
}

# Enable completion if this is a terminal
[ ! -t 1 ] || {
	function _load() {
		COMPREPLY=($(cd "$HOME/.bash.d/on-demand" && ls "$2"*))
	}
	complete -F _load load
}

##################
# Homebrew setup #
##################
[ ! -r ~/.HOMEBREW_GITHUB_API_TOKEN ] || {
	read -d '' -r HOMEBREW_GITHUB_API_TOKEN <~/.HOMEBREW_GITHUB_API_TOKEN
	export HOMEBREW_GITHUB_API_TOKEN
}

has-command brew || /usr/bin/ruby -e "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

###########
# Node.js #
###########

# Node is managed using Volta https://volta.sh/
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

pnpm() {
	declare version="$([ ! -r package.json ] || jq -Mr '.devDependencies?.pnpm // empty' <package.json 2>/dev/null || true)"
	npm x -q --yes --no-install "pnpm@$version" -- ${1+"$@"}
}

#########
# Other #
#########

# If rbenv is installed, start it (it's fast enough)
! has-command rbenv || eval "$(rbenv init -)"

# Input piper
__jc_pipe_input() {
	case "${1:--}" in
		http?(s):*)
			curl -sL "$1"
			;;
		-)
			cat
			;;
		*)
			cat "$1"
			;;
	esac
}

# YAML prettifier
yaml-beautify() {
	__jc_pipe_input "${1:--}" | npx prettier --single-quote --stdin-filepath foo.yaml
}

# JSON to YAML converter
function json-to-yaml() {
	__jc_pipe_input "${1:--}" | yq eval -P | yaml-beautify
}

# Grep looks better with color
alias grep='grep --color'

# Spotlight on/off
#
# $1: on/off
alias spotlight='sudo mdutil -a -i'

# So does ls
! has-command gls || alias ls='gls --color=auto --show-control-chars'

# FIXME: I remember this broke a third-party script before.
! has-command gnutar || alias tar='gnutar'

# Download stuff
! has-command aria2c || alias dl='aria2c -x5 --http-accept-gzip=true --use-head=true'

# Remove the quarantine flag on downloaded stuff
! has-command xattr || alias unquarantine='xattr -drv com.apple.quarantine'

# Copy bare stuff
! has-command ditto || alias copy='ditto --norsrc --noextattr --noqtn --noacl'

# FIXME: don't hardcode those paths
! has-command ncftpput || alias copy-movie="ncftpput -z -f '$HOME/.ncftp/hosts/mediaplayer' T_Drive/Films"

# Show a palette: fixed colors 1-15, then 24-bit gray ramp
# Shows immediately if 24-bit mode is supported
color-test() {
	declare col=$(tput cols)

	# 24-bit gradient
	while ((col > 15)); do
		printf '\x1b[48;2;%u;%u;%um ' $col $((col / 2)) $((col / 3))
		col=$((--col))
	done

	# 4-bit color map for the end
	for col in {1..15}; do
		printf '\x1b[48;5;%sm ' $col
	done

	printf '\x1b[0m\n'
}

# Open a SHA-1 as a magnet link
magnetize() {
	open 'magnet:?xt=urn:btih:'"$1"
}

# Find hardlinks to a file
#
# $1  File
# $2  (Optional) Directory to consider. Defaults to current directory.
# $3… (Optional) Extra parameters for "find", to restrict results.
hardlinks() {
	declare f="$1" dir="$2"
	shift
	if [ -d "$dir" ]; then
		shift
	else
		dir="$(pwd)"
	fi
	declare $(stat -s "$f")
	find "$dir" -inum $st_ino $@
}

# Find broken links
#
# $1  Directory to scan
brokenlinks() {
	declare dir="$1"
	shift
	NSUnbufferedIO=YES gfind -O3 "$dir" -xtype l -print0 | xargs -0 ${1+"$@"}
}

# VS.Code launcher
code() {
	declare content="$(realpath /usr/local/bin/code)"
	content="${content%/Contents*}/Contents"
	ELECTRON_RUN_AS_NODE=1 "$content/MacOS/Electron" "$content/Resources/app/out/cli.js" --disable-gpu "$@"
}

# Paste HTML content as markup, not plain text
htmlpaste() {
	osascript -e 'the clipboard as «class HTML»' | perl -ne 'print chr foreach unpack("C*",pack("H*",substr($_,11,-3)))'
}

# SSH config backup
ssh-config-backup() (
	declare ARCHIVE="ssh-config-$$.tar.bz2"
	set -e -u -o pipefail
	cd "$HOME"
	mkdir -p ".dotfiles/install"
	tar --posix -cf "$ARCHIVE" .ssh
	chmod 600 "$ARCHIVE"
	openssl enc -e -aes256 -in "$ARCHIVE" -out ".dotfiles/install/ssh-config.tbe"
	rm "$ARCHIVE"
)

#####################
# Interactive shell #
#####################
[ ! -t 1 ] || {
	# Keys for history search
	bind '"\e[5~": history-search-backward' # PgUp
	bind '"\e[6~": history-search-forward'  # PgDn

	# Bash completion
	if [ -r /usr/local/etc/profile.d/bash_completion.sh ]; then
		. /usr/local/etc/profile.d/bash_completion.sh
	elif [ -r /usr/local/etc/bash_completion ]; then
		. /usr/local/etc/bash_completion
	elif [ -r /usr/local/etc/bash_completion.d ]; then
		for X in /usr/local/etc/bash_completion.d/*; do
			. $X
		done
	fi

	# iTerm integration
	[ -f ~/.iterm2_shell_integration.bash ] || (
		/usr/bin/curl -fsSL -o ~/.iterm2_shell_integration.bash.tmp https://iterm2.com/shell_integration/bash
		mv ~/.iterm2_shell_integration.bash{.tmp,}
	)
	[ ! -r ~/.iterm2_shell_integration.bash ] || . ~/.iterm2_shell_integration.bash

	# thefuck!
	! has-command thefuck || {
		# Lazy initialization of thefuck
		function fuck() {
			# Unset stub
			unset -f fuck

			# Install real alias
			eval "$(thefuck --alias)"

			# Execute requested command
			fuck ${1+"$@"}
		}

		# Autofuck!
		function command_not_found_handle() {
			fuck "$@"
		}
	}

	# Git Status
	. "$DOTFILES_DIR/.gitstatus/gitstatus.plugin.sh"
	__jc_ps1="$PS1"
	__jc_gitstatus_prompt_update() {
		GITSTATUS_PROMPT=""
		PS1="$__jc_ps1"

		gitstatus_query "$@" || return 1                  # error
		[[ "$VCS_STATUS_RESULT" == ok-sync ]] || return 0 # not a git repo

		# These somehow fuck up bash history in iTerm2
		local reset=$'\033[0m'             # no color
		local clean=$'\033[38;5;076m'      # green foreground
		local untracked=$'\033[38;5;014m'  # teal foreground
		local modified=$'\033[38;5;011m'   # yellow foreground
		local conflicted=$'\033[38;5;196m' # red foreground

		local p

		local where # branch name, tag or commit
		if [[ -n "$VCS_STATUS_LOCAL_BRANCH" ]]; then
			where="$VCS_STATUS_LOCAL_BRANCH"
		elif [[ -n "$VCS_STATUS_TAG" ]]; then
			p+='\['"${reset}"'\]#'
			where="$VCS_STATUS_TAG"
		else
			p+='\['"${reset}"'\]@'
			where="${VCS_STATUS_COMMIT:0:8}"
		fi

		((${#where} > 32)) && where="${where:0:12}…${where: -12}" # truncate long branch names and tags
		p+='\['"${clean}"'\]'"${where}"

		((VCS_STATUS_COMMITS_BEHIND)) && p+=' \['"${clean}"'\]⇣'"${VCS_STATUS_COMMITS_BEHIND}"
		((VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND)) && p+=" "
		((VCS_STATUS_COMMITS_AHEAD)) && p+='\['"${clean}"'\]⇡'"${VCS_STATUS_COMMITS_AHEAD}"
		((VCS_STATUS_STASHES)) && p+=' \['"${clean}"'\]*'"${VCS_STATUS_STASHES}"
		[[ -n "$VCS_STATUS_ACTION" ]] && p+=' \['"${conflicted}"'\]'"${VCS_STATUS_ACTION}"
		((VCS_STATUS_NUM_CONFLICTED)) && p+=' \['"${conflicted}"'\]~'"${VCS_STATUS_NUM_CONFLICTED}"
		((VCS_STATUS_NUM_STAGED)) && p+=' \['"${modified}"'\]+'"${VCS_STATUS_NUM_STAGED}"
		((VCS_STATUS_NUM_UNSTAGED)) && p+=' \['"${modified}"'\]!'"${VCS_STATUS_NUM_UNSTAGED}"
		((VCS_STATUS_NUM_UNTRACKED)) && p+=' \['"${untracked}"'\]?'"${VCS_STATUS_NUM_UNTRACKED}"

		GITSTATUS_PROMPT="${p}"'\['"${reset}"'\]'
		PS1+="$GITSTATUS_PROMPT "
	}

	gitstatus_stop && gitstatus_start -s -1 -u -1 -c -1 -d -1

	if [[ "${__bp_imported:-}" == "defined" ]]; then
		precmd_functions+=(__jc_gitstatus_prompt_update)
	else
		PROMPT_COMMAND="__jc_gitstatus_prompt_update${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
	fi
}

# Site-specific
[ ! -r "$HOME/.bash_profile.local" ] || . "$HOME/.bash_profile.local"

export BASH_PROFILE_SOURCED=1

# ex: noet ci pi sts=0 sw=2 ts=2 filetype=sh
