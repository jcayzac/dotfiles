# Configuration
DEFAULT_LOCALE='en_US.UTF-8'

# Environment
set +e +u +o pipefail
export \
	ANDROID_HOME="$HOME/Library/Android/sdk" \
	ANDROID_SDK_ROOT="$HOME/Library/Android/sdk" \
	ANDROID_NDK_HOME="$HOME/Library/Android/sdk/ndk-bundle" \
	GIT_PS1_SHOWDIRTYSTATE=1 \
	GIT_PS1_SHOWSTASHSTATE=1 \
	GIT_PS1_SHOWUNTRACKEDFILES=1 \
	GIT_PS1_SHOWUPSTREAM='verbose name' \
	GOPATH="$HOME/.go" \
	GROOVY_HOME='/usr/local/opt/groovy/libexec' \
	GREP_COLOR='01' \
	HISTCONTROL='erasedups' \
	HISTFILESIZE=10000 \
	HISTIGNORE='&:ls:cd:pwd:[bf]g:exit:fuck' \
	HOMEBREW_NO_ANALYTICS=1 \
	HOMEBREW_INSTALL_BADGE='  🥃  ' \
	HOMEBREW_INSTALL_CLEANUP=1 \
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
	PS1='\[\033[01;32m\]\u\[\033[01;34m\] \w \[\033[0m' \
	SDKMAN_DIR="$HOME/.sdkman"

umask 022          # default mode = 755
ulimit -S -n 10240 # raise number of open file handles
shopt -s cmdhist   # save multiline commands in history
shopt -s globstar  # support ** in glob patterns
tabs -2            # use 2sp-wide tabs

# Enable extra builtins if available
enable-loadable-builtin() {
	declare module="$1"
	shift
	enable -f "/usr/local/opt/bash/lib/bash/$module" ${1+"$@"}
}
for _ in basename dirname finfo head realpath sleep strftime tee unlink
do
	enable-loadable-builtin "$_" "$_"
done
enable-loadable-builtin "truefalse" "true" "false"

load () {
	. "$HOME/.bash.d/$1"
}

[ ! -t 1 ] || {
	function _load () {
		COMPREPLY=($( cd "$HOME/.bash.d" && ls "$2"*))
	}
	complete -F _load load
}

function_exists() {
	declare -f -F $1 >/dev/null
	return $?
}

alias has-command='command >&- 2>&- -v'

join_strings() {
	declare d="$1"
	printf '%s' "$2"
	shift 2
	printf '%s' "${@/#/$d}"
}

PATHS=(
	# User
	"$HOME/.prefix/bin"

	# Go
	"$HOME/.go/bin"
	"/usr/local/opt/go/libexec/bin"

	# Android
	"$ANDROID_HOME/tools"
	"$ANDROID_HOME/tools/bin"
	"$ANDROID_HOME/platform-tools"

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

has-command brew || {
	/usr/bin/ruby -e "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew tap Homebrew/bundle
}

[ -f ~/.iterm2_shell_integration.bash ] || /usr/bin/curl -fsSL -o ~/.iterm2_shell_integration.bash https://iterm2.com/misc/bash_startup.in

[ ! -f /usr/local/etc/bash_completion ] || . /usr/local/etc/bash_completion

# changing PS1 is impossible after iTerm2 shell integration is enabled
function_exists __git_ps1 && export PS1=${PS1}'\[\033[01;33m\]$(__git_ps1 "[%s] ")\[\033[00m\]'
[ ! -t 1 ] || [ ! -f ~/.iterm2_shell_integration.bash ] || . ~/.iterm2_shell_integration.bash

[ ! -f ~/.nvm/nvm.sh ] || {
	# Lazy initialization of NVM
	function nvm() {
		unset -f nvm node npm
		. ~/.nvm/nvm.sh
		nvm use stable >/dev/null
		nvm ${1+"$@"}
	}

	function node() {
		nvm --version >&- 2>&-
		node ${1+"$@"}
	}

	function npm() {
		nvm --version >&- 2>&-
		npm ${1+"$@"}
	}
}

[ ! -r "$SDKMAN_DIR/bin/sdkman-init.sh" ] || {
	# Lazy initialization of SDKMAN
	function sdk() {
		unset -f sdk
		. "$SDKMAN_DIR/bin/sdkman-init.sh"
		sdk ${1+"$@"}
	}
}

! has-command yarn || {
	export PATH="$HOME/.yarn/bin:$PATH"
}

! has-command rbenv || eval "$(rbenv init -)"

! has-command thefuck || {
	# Lazy initialization of thefuck
	function fuck() {
		unset -f fuck
		eval "$(thefuck --alias)"
		fuck ${1+"$@"}
	}
}

# aliases and custom commands

alias grep='grep --color'
! has-command gls       || alias ls='gls --color=auto --show-control-chars'
! has-command gnutar    || alias tar='gnutar'
! has-command aria2c    || alias dl='aria2c -x5 --http-accept-gzip=true --use-head=true'
! has-command xattr     || alias unquarantine='xattr -drv com.apple.quarantine'
! has-command ditto     || alias copy='ditto --norsrc --noextattr --noqtn --noacl'
! has-command ncftpput  || alias copy-movie="ncftpput -z -f '$HOME/.ncftp/hosts/mediaplayer' T_Drive/Films"
[ ! -x "$HOME/.iTerm2/imgcat" ] || alias imgcat="$HOME/.iTerm2/imgcat"
[ ! -x "$HOME/.iTerm2/it2dl"  ] || alias it2dl="$HOME/.iTerm2/it2dl"

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

htmlpaste() {
	osascript -e 'the clipboard as «class HTML»' | perl -ne 'print chr foreach unpack("C*",pack("H*",substr($_,11,-3)))'
}

update_env() {
	[ ! -t 1 ] || printf "\x1b[2J\x1b[H"
	__msg() {
		printf "\n\x1b[40;34;1m\x1b[K\n  🤖  %s \x1b[K\n\x1b[K\x1b[0m\n\n" "$1"
	}

	! has-command brew || {
		__msg "Updating Homebrew…"
		brew update
		brew upgrade
		brew cleanup -s
		brew prune
	}

	! has-command gem || {
		__msg "Updating Ruby gems…"
		gem sources -q -u
		gem update -q -N --no-update-sources
		gem clean -q >&- 2>&-
	}

	if has-command yarn
	then
		__msg "Updating Yarn package…"
		yarn global upgrade --latest -s
	elif [ -x "${NVM_BIN:-/nowhere}/npm" ]
	then
		__msg "Updating NPM packages…"
		"$NVM_BIN/npm" -g update -q
	fi

	# FIXME: might break if the "java" bash extension isn't loaded
	! has-command flutter || {
		__msg "Updating Flutter…"
		flutter upgrade
	}

	! has-command apm || {
		__msg "Updating Atom packages…"
		apm upgrade --no-confirm
	}

	if has-command sdk
	then
		__msg "Updating SDKMAN…"
		sdk selfupdate
	else
		__msg "Installing SDKMAN…"
		curl -s "https://get.sdkman.io" | bash
		. "$SDKMAN_DIR/bin/sdkman-init.sh"
	fi

	! has-command pod || {
		__msg "Updating Cocoapods specs…"
		pod repo update --silent
	}

	printf "\n\x1b[40;32;1m\x1b[K\n  🚀  %s \x1b[K\n\x1b[K\x1b[0m\n\n" "Ready to take off!"
}


# extra setup
#/usr/bin/find ~/Library -flags hidden -maxdepth 0 -exec /usr/bin/chflags nohidden "{}" +
#
#{ defaults read  com.apple.dock persistent-others | grep '"recents-tile"' >&- 2>&- ; } || \
#  defaults write com.apple.dock persistent-others -array-add '{ "tile-data" = { "list-type" = 1; }; "tile-type" = "recents-tile"; }'
#
# Enable subpixel font rendering on non-Apple LCDs
#defaults write -g AppleFontSmoothing -int 2

# Site-specific
[ ! -f "$HOME/.bash_profile.local" ] || . "$HOME/.bash_profile.local"

# ex: noet ci pi sts=0 sw=2 ts=2 filetype=sh
