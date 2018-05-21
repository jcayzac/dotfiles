# Configuration
DEFAULT_JAVA='1.8'
DEFAULT_LOCALE='en_US.UTF-8'

# Environment
set +e +u +o pipefail
export \
	ANDROID_HOME="$HOME/Library/Android/sdk" \
	ANDROID_SDK_ROOT="$HOME/Library/Android/sdk" \
	ANDROID_NDK_HOME="$HOME/Library/Android/sdk/ndk-bundle" \
	ANT_HOME='/usr/local/opt/ant/libexec' \
	GIT_PS1_SHOWDIRTYSTATE=1 \
	GIT_PS1_SHOWSTASHSTATE=1 \
	GIT_PS1_SHOWUNTRACKEDFILES=1 \
	GIT_PS1_SHOWUPSTREAM='verbose name' \
	GOPATH="$HOME/.go" \
	GRADLE_HOME='/usr/local/opt/gradle' \
	GROOVY_HOME='/usr/local/opt/groovy/libexec' \
	GREP_COLOR='01' \
	HISTCONTROL='erasedups' \
	HISTFILESIZE=10000 \
	HISTIGNORE='&:ls:cd:pwd:[bf]g:exit:fuck' \
	HOMEBREW_NO_ANALYTICS=1 \
	HOMEBREW_INSTALL_BADGE='  🥃  ' \
    JAVA7_HOME="$(/usr/libexec/java_home -v 1.7 2>/dev/null || true)" \
    JAVA8_HOME="$(/usr/libexec/java_home -v 1.8 2>/dev/null || true)" \
    JAVA9_HOME="$(/usr/libexec/java_home -v 9 2>/dev/null || true)" \
    JAVA10_HOME="$(/usr/libexec/java_home -v 10 2>/dev/null || true)" \
    JAVA_HOME="$(/usr/libexec/java_home -v "$DEFAULT_JAVA" 2>/dev/null || true)" \
	LANG="$DEFAULT_LOCALE" \
	LC_COLLATE="$DEFAULT_LOCALE" \
	LC_CTYPE="$DEFAULT_LOCALE" \
	LC_MESSAGES="$DEFAULT_LOCALE" \
	LC_MONETARY="$DEFAULT_LOCALE" \
	LC_NUMERIC="$DEFAULT_LOCALE" \
	LC_TIME="$DEFAULT_LOCALE" \
	LC_ALL= \
	LESS_TERMCAP_us=$'\E[01;32m' \
	LESS_TERMCAP_ue=$'\e[0m' \
	LESS_TERMCAP_md=$'\e[01m' \
	LESS_TERMCAP_me=$'\e[0m' \
	LESS='-FXRSN~g' \
	LESSOPEN="|/usr/local/bin/lesspipe.sh %s" \
	LESS_ADVANCED_PREPROCESSOR=1 \
	LS_COLORS='do=01;35:*.dmg=01;31:*.aac=01;35:*.img=01;31:*.tar=01;31:di=01;34:rs=0:*.qt=01;35:ex=01;32:ow=34;42:*.mov=01;35:*.jar=01;31:or=40;31;01:*.pvr=01;35:*.ogm=01;35:*.svgz=01;35:*.toast=01;31:*.asf=01;35:*.bz2=01;31:*.rar=01;31:*.sparsebundle=01;31:*.ogg=01;35:*.m2v=01;35:*.svg=01;35:*.sparseimage=01;31:*.7z=01;31:*.mp4=01;35:*.tbz2=01;31:bd=40;33;01:*.vob=01;35:*.zip=01;31:*.avi=01;35:*.mp3=01;35:so=01;35:*.m4a=01;35:ln=01;36:*.tgz=01;31:tw=30;42:*.png=01;35:*.wmv=01;35:sg=30;43:*.rpm=01;31:*.gz=01;31:*.tbz=01;31:*.mkv=01;35:*.mpg=01;35:*.pkg=01;31:*.mpeg=01;35:*.iso=01;31:ca=30;41:pi=41;33:*.wav=01;35:su=37;41:*.jpg=01;35:st=37;44:cd=40;33;01:*.m4v=01;35:mh=01;36:' \
	MANPATH="$HOME/.prefix/share/man:/usr/local/share/man:/usr/share/man" \
	MAVEN_HOME='/usr/local/opt/maven' \
	PS1='\[\033[01;32m\]\u\[\033[01;34m\] \w \[\033[0m'

umask 022			# default mode = 755
ulimit -S -n 10240	# raise number of open file handles
shopt -s cmdhist	# save multiline commands in history
tabs -4				# use 4sp-wide tabs

function_exists() {
	declare -f -F $1 >/dev/null
	return $?
}

join_strings() {
	local d="$1"
	shift
	printf '%s' "$1"
	shift
	printf '%s' "${@/#/$d}"
}

PATHS=(
	# User
	"$HOME/.prefix/bin"

	# Go
	"$HOME/.go/bin"
	"/usr/local/opt/go/libexec/bin"

	# Android
	"$GRADLE_HOME/bin"
	"$ANDROID_HOME/tools"
	"$ANDROID_HOME/tools/bin"
	"$ANDROID_HOME/platform-tools"
	"$MAVEN_HOME/bin"
	"/usr/local/opt/ant/bin"

	# Local
	"/usr/local/bin"
	"/usr/local/sbin"

	# System
	"/usr/bin"
	"/usr/sbin"
	"/bin"
	"/sbin"
)

export PATH="$(join_strings : ${PATHS[*]})"

[ ! -t 1 ] || {
	bind '"\e[5~": history-search-backward' # bind PgUp
	bind '"\e[6~": history-search-forward'  # bind PgDn

	# Show a palette: fixed colors 1-15, then 24-bit gray ramp
	# Shows immediately if 24-bit mode is supported.
	declare COL COLS
	read -r COLS < <(tput cols)
	for ((COL=COLS; COL>15; --COL))
	do
		printf "\x1b[48;2;$COL;$((COL/2));$((COL/3))m "
	done
	for COL in {1..15}
	do
		printf "\x1b[48;5;%sm " "$COL"
	done

	printf "\x1b[0m\n"
}

# Dependencies
[ ! -f ~/.HOMEBREW_GITHUB_API_TOKEN ] || {
	read -d '' -r HOMEBREW_GITHUB_API_TOKEN <~/.HOMEBREW_GITHUB_API_TOKEN
	export HOMEBREW_GITHUB_API_TOKEN
}

which brew >/dev/null 2>&1 || {
	/usr/bin/ruby -e "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew tap Homebrew/bundle
}

[ -f ~/.iterm2_shell_integration.bash ] || /usr/bin/curl -fsSL -o ~/.iterm2_shell_integration.bash https://iterm2.com/misc/bash_startup.in

[ ! -f /usr/local/etc/bash_completion ] || . /usr/local/etc/bash_completion

# changing PS1 is impossible after iTerm2 shell integration is enabled
function_exists __git_ps1 && export PS1=${PS1}'\[\033[01;33m\]$(__git_ps1 "[%s] ")\[\033[00m\]'
[ ! -t 1 ] || [ ! -f ~/.iterm2_shell_integration.bash ] || . ~/.iterm2_shell_integration.bash

[ ! -f ~/.nvm/nvm.sh ]      || { . ~/.nvm/nvm.sh; nvm use stable >/dev/null; }

if which rbenv   >/dev/null 2>&1; then eval "$(rbenv init -)"; fi
if which thefuck >/dev/null 2>&1; then eval "$(thefuck --alias)"; fi

# aliases and custom commands

alias grep='grep --color'
alias grepjava='grep --include \*.java'
if which gls    >/dev/null 2>&1; then alias ls="gls --color=auto --show-control-chars"; fi
if which gnutar >/dev/null 2>&1; then alias tar='gnutar'; fi
[ ! -x "$HOME/.iTerm2/imgcat" ] || alias imgcat="$HOME/.iTerm2/imgcat"
[ ! -x "$HOME/.iTerm2/it2dl" ]  || alias it2dl="$HOME/.iTerm2/it2dl"

dl() {
	aria2c -x5 --http-accept-gzip=true --use-head=true ${1+"$@"}
}

copy() {
	# Fucked up over SMB/CIFS :-(
	# rsync -c --no-xattrs --no-whole-file --inplace --progress ${1+"$@"}
	ditto --norsrc --noextattr --noqtn --noacl ${1+"$@"}
}

copy-movie() {
	ncftpput -z -f "$HOME/.ncftp/hosts/mediaplayer" T_Drive/Films ${1+"$@"}
}

magnetize() {
	open 'magnet:?xt=urn:btih:'"$1"
}

hardlinks() {
	# Usage: hardlinks <file> [dir] [extra find arguments]
	local FN="$1" DIR="$2"
	shift
	if [ -d "$DIR" ]
	then
		shift
	else
		DIR='.'
	fi
	local $(stat -s "$FN")
	find "$DIR" -inum $st_ino $@
}

brokenlinks() {
	local dir="$1"
	shift
	NSUnbufferedIO=YES gfind -O3 "$dir" -xtype l -print0 | xargs -0 ${1+"$@"}
}

unquarantine() {
	xattr -dr com.apple.quarantine ${1+"$@"}
}

update_env() {
	[ ! -t 1 ] || printf "\x1b[2J\x1b[H"
	__msg() {
		printf "\n\x1b[40;34;1m\x1b[K\n  🤖  %s \x1b[K\n\x1b[K\x1b[0m\n\n" "$1"
	}

	if which brew >/dev/null 2>&1
	then
		__msg "Updating Homebrew…"
		brew update
		brew upgrade --cleanup
		brew cleanup -s
		brew cask cleanup
	fi

	if which gem >/dev/null 2>&1
	then
		__msg "Updating Ruby gems…"
		gem sources -q -u
		gem update -q -N --no-update-sources
		gem clean -q >/dev/null 2>&1
	fi

	[ ! -x "${NVM_BIN:-/nowhere}/npm" ] || {
		__msg "Updating Node packages…"
		"$NVM_BIN/npm" -g update -q
	}

	if which apm >/dev/null 2>&1
	then
		__msg "Updating Atom packages…"
		apm upgrade --no-confirm
	fi

	# Skipping, as filters don't work the way they should
	#if which android >/dev/null 2>&1
	#then
	#	__msg "Updating the Android tools…"
	#	expect -c '
	#	set timeout -1;
	#	spawn android update sdk --no-ui --filter 1,2
	#	expect {
	#		"Do you accept the license" { exp_send "y\r" ; exp_continue }
	#		eof
	#	}
	#	'
	#fi

	if which pod >/dev/null 2>&1
	then
		__msg "Updating Cocoapods specs…"
		pod repo update --silent
	fi

	printf "\n\x1b[40;32;1m\x1b[K\n  🚀  %s \x1b[K\n\x1b[K\x1b[0m\n\n" "Ready to take off!"
}


# extra setup
#/usr/bin/find ~/Library -flags hidden -maxdepth 0 -exec /usr/bin/chflags nohidden "{}" +
#
#{ defaults read  com.apple.dock persistent-others | grep '"recents-tile"' >/dev/null 2>&1; } || \
#  defaults write com.apple.dock persistent-others -array-add '{ "tile-data" = { "list-type" = 1; }; "tile-type" = "recents-tile"; }'
#
# Enable subpixel font rendering on non-Apple LCDs
#defaults write -g AppleFontSmoothing -int 2

# Site-specific
[ ! -f "$HOME/.bash_profile.local" ] || . "$HOME/.bash_profile.local"

# ex: noet ci pi sts=0 sw=4 ts=4 filetype=sh
