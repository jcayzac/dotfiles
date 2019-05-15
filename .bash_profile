set +e +u +o pipefail # continue on errors
umask 022             # default mode = 755
ulimit -S -n 10240    # raise number of open file handles
shopt -s cmdhist      # save multiline commands in history
shopt -s globstar     # support ** in glob patterns
tabs -2               # use 2sp-wide tabs
[ ! -t 1 ] || {       # bind keys for history search if this is a terminal
	bind '"\e[5~": history-search-backward' # PgUp
	bind '"\e[6~": history-search-forward'  # PgDn
}

##################
# Base utilities #
##################

# Find if something is a command (better alternative to "which", "type" and others)
#
# $1  Command name
alias has-command='command >/dev/null 2>&1 -v'

# Join an array of strings.
#
# $1  Separator
# $2… Strings
join_strings() {
	declare d="$1"
	printf '%s' "$2"
	shift 2
	printf '%s' "${@/#/$d}"
}

####################
# Base environment #
####################
DEFAULT_LOCALE='en_US.UTF-8'

export \
	ANDROID_HOME="$HOME/Library/Android/sdk" \
	ANDROID_SDK_ROOT="$HOME/Library/Android/sdk" \
	ANDROID_NDK_HOME="$HOME/Library/Android/sdk/ndk-bundle" \
	GIT_PS1_SHOWDIRTYSTATE=1 \
	GIT_PS1_SHOWSTASHSTATE=1 \
	GIT_PS1_SHOWUNTRACKEDFILES=1 \
	GIT_PS1_SHOWUPSTREAM='verbose name' \
	GOPATH="$HOME/.go" \
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

PATHS=(
	# User
	"$HOME/.prefix/bin"

	# Rust
	"$HOME/.cargo/bin"

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
	'fdflags' \
	'finfo' \
	'head' \
	'mypid enable_mypid' \
	'realpath' \
	'sleep' \
	'strftime' \
	'tee' \
	'unlink' \
	'truefalse true false'  \

do
	enable-loadable-builtin $_
done

# Enable $MYPID
enable_mypid

###########################################################
# Extra libraries of bash functions not loaded at startup #
###########################################################

# Load a library
#
# $1  Library name
load () {
	. "$HOME/.bash.d/$1"
}

# Enable completion if this is a terminal
[ ! -t 1 ] || {
	function _load () {
		COMPREPLY=($( cd "$HOME/.bash.d" && ls "$2"*))
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

###################
# Bash completion #
###################

if [ -r /usr/local/etc/bash_completion ]
then
	. /usr/local/etc/bash_completion
elif [ -r /usr/local/etc/bash_completion.d ]
then
	for X in /usr/local/etc/bash_completion.d/*
	do
		. $X
	done
fi

#######
# Git #
#######

# Install git prompt into PS1
# Note: changing PS1 is impossible after iTerm2 shell integration is enabled
! has-command __git_ps1 || export PS1=${PS1}'\[\033[01;33m\]$(__git_ps1 "[%s] ")\[\033[00m\]'

#####################
# iTerm integration #
#####################

# If this is a terminal…
[ ! -t 1 ] || {

	# …and the integrations aren't installed, install them
	[ -f ~/.iterm2_shell_integration.bash ] || (
		set -e
		/usr/bin/curl -fsSL -o ~/.iterm2_shell_integration.bash.tmp https://iterm2.com/misc/bash_startup.in
		mv ~/.iterm2_shell_integration.bash{.tmp,}
	)

	# …and the integrations are installed, load them
	[ ! -r ~/.iterm2_shell_integration.bash ] || . ~/.iterm2_shell_integration.bash
}

###########
# Node.js #
###########

# If NVM is installed, setup stubs to lazily load nvm, node and npm.
# This greatly reduce startup time, as NVM is quite slow to kick in.
[ ! -r ~/.nvm/nvm.sh ] || {
	function nvm() {
		unset -f nvm node npm
		. ~/.nvm/nvm.sh
		nvm use node >/dev/null
		[ ! -r ~/.nvm/bash_completion ] || . ~/.nvm/bash_completion
		nvm ${1+"$@"}
	}

	function node() {
		nvm --version >/dev/null 2>&1
		node ${1+"$@"}
	}

	function npm() {
		nvm --version >/dev/null 2>&1
		npm ${1+"$@"}
	}
}

# If Yarn is installed, add ~/.yarn/bin to the path
! has-command yarn || {
	export PATH="$HOME/.yarn/bin:$PATH"
}

##########
# SDKMAN #
##########

declare __sdkman_script_path="$SDKMAN_DIR/bin/sdkman-init.sh"
[ ! -r "$__sdkman_script_path" ] || {
	# Lazy initialization of SDKMAN
	function sdk() {
		unset -f sdk
		. "$__sdkman_script_path"
		sdk ${1+"$@"}
	}
}

#########
# Other #
#########

# If rbenv is installed, start it (it's fast enough)
! has-command rbenv || eval "$(rbenv init -)"

# If thefuck is installed, install a stub to lazily load it
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
}

# Grep looks better with color
alias grep='grep --color'

# So does ls
! has-command gls       || alias ls='gls --color=auto --show-control-chars'

# FIXME: I remember this broke a third-party script before.
! has-command gnutar    || alias tar='gnutar'

# Download stuff
! has-command aria2c    || alias dl='aria2c -x5 --http-accept-gzip=true --use-head=true'

# Remove the quarantine flag on downloaded stuff
! has-command xattr     || alias unquarantine='xattr -drv com.apple.quarantine'

# Copy bare stuff
! has-command ditto     || alias copy='ditto --norsrc --noextattr --noqtn --noacl'

# FIXME: don't hardcode those paths
! has-command ncftpput  || alias copy-movie="ncftpput -z -f '$HOME/.ncftp/hosts/mediaplayer' T_Drive/Films"

# Show a palette: fixed colors 1-15, then 24-bit gray ramp
# Shows immediately if 24-bit mode is supported
color-test() {
	declare col=$(tput cols)

	# 24-bit gradient
	while (( col > 15))
	do
		printf '\x1b[48;2;%u;%u;%um ' $col $((col/2)) $((col/3))
		col=$(( --col ))
	done

	# 4-bit color map for the end
	for col in {1..15}
	do
		printf '\x1b[48;5;%sm ' $col
	done

	printf '\x1b[0m\n'
}

# Open a SHA-1 has a magnet link
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
	if [ -d "$dir" ]
	then
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
	open -b com.microsoft.VSCode ${1+"$@"} --args --disable-gpu
}

# Paste HTML content as markup, not plain text
htmlpaste() {
	osascript -e 'the clipboard as «class HTML»' | perl -ne 'print chr foreach unpack("C*",pack("H*",substr($_,11,-3)))'
}

# Update stuff
__update_stuff_sub() {
	case "$1" in
		brew*)
			! has-command brew || {
				echo "Updating Homebrew…"
				export HOMEBREW_NO_COLOR=1
				brew update
				brew upgrade
				nohup brew cleanup -s >/dev/null 2>&1 &
			}
			;;

		gems*)
			! has-command gem || {
				echo "Updating Ruby gems…"
				gem sources -q -u
				gem update -q -N --no-update-sources
				nohup gem clean -q >/dev/null 2>&1 &
			}
			;;

		node*)
			! has-command nvm || {
				echo "Updating NVM…"
				git -C ~/.nvm fetch -qtpP
				declare current_version="$(git -C ~/.nvm describe)"
				declare next_version="$(git -C ~/.nvm describe --abbrev=0 origin/master)"
				[ "$current_version" == "$next_version" ] || {
					git -C ~/.nvm checkout "$next_version"
					unset -f nvm node npm
					. ~/.nvm/nvm.sh
				}
				nvm install -s node --latest-npm --reinstall-packages-from=node
			}
			! has-command npm || {
				echo "Updating NPM packages…"
				npm -g update -q
			}
			! has-command yarn || {
				echo "Updating Yarn packages…"
				yarn global upgrade --latest -s
			}
			;;

		flutter*)
			! has-command flutter || {
				echo "Updating Flutter…"
				flutter upgrade
			}
		 	;;

		atom*)
			! has-command apm || {
				echo "Updating Atom packages…"
				apm upgrade --no-confirm --no-color
			}
			;;

		sdk*)
			export sdkman_colour_enable="false"
			if [ -r "$__sdkman_script_path" ]
			then
				echo "Updating SDKMAN…"
				. "$__sdkman_script_path"
				sdk selfupdate
				yes | sdk update
				for _ in archives broadcast temp
				do
					sdk flush $_
				done
			else
				echo "Installing SDKMAN…"
				curl -s "https://get.sdkman.io" | bash
			fi
			;;

		pods*)
			! has-command pod || {
				echo "Updating Cocoapods specs…"
				pod repo update --silent
			}
			;;

		rust*)
			! has-command rustup || {
				echo "Updating Rust toolchain…"
				rustup update
				D="$HOME/.bash_completion.d"
				[ ! -d "$D" ] || mkdir -p "$D"
				rustup completions bash >"$D/rustup"
				rustup completions bash cargo >"$D/cargo"
			}
			;;
	esac
}

update-stuff() {
	has-command parallel || brew install parallel
	[ "${1:-}" != 'times' ] || declare LOG="${TMPDIR}update_stuff.$$.log"

	# Save stome state
	declare nvm_verinfo="$(nvm --version 2>&1 || true)"
	declare thefuck_verinfo="$(thefuck --version 2>&1 || true)"

	# Export stuff needed in __update_stuff_sub
	export -f sdk || true
	export -f __update_stuff_sub
	export __sdkman_script_path

	printf '\x1b[2J\x1b[0;0f'
	SHELL="$BASH" parallel \
		-j0 \
		${LOG+--joblog "$LOG"} \
		--line-buffer \
		--rpl '{tag} my @col = split /\s+/, $arg[1]; $_=sprintf("\x1b[0m\x1b[38;2;%i;%i;%im%8s\x1b[10G%s\x1b[12G", 127 + (8 * int rand(16)), 95 + (8 * int rand(20)), 127 + (8 * int rand(16)), $col[0], $col[1]);' \
		--tagstring '{tag}' \
		__update_stuff_sub <<-EOT
			atom		⚛️
			brew		☕️
			flutter		🐦
			gems		💎
			node		🔮
			rust		⚙️
			sdk			📦
			EOT

	function __color() { printf '\x1b[0m\x1b[38;2;%i;%i;%im' $1 ${2:-$1} ${3:-$1}; }

	# Reload some commands
	function msg() { printf '\x1b[10G%s\x1b[13G%s\n' "$1" "$2"; }
	function msg_reload() { msg '🌀' "Reloading ${1}…"; }
	__color 128

	[ ! -r ~/.nvm/nvm.sh ] || [ "$nvm_verinfo" == "$(nvm --version 2>&1 || true)" ] || {
		msg_reload 'NVM'
		unset -f nvm node npm
		. ~/.nvm/nvm.sh
		nvm use node >/dev/null
	}
	! has-command thefuck || [ "$thefuck_verinfo" == "$(thefuck --version 2>&1 || true)" ] || {
		msg_reload 'THEFUCK'
		unset -f fuck
		eval "$(thefuck --alias)"
	}
	[ ! -r "$__sdkman_script_path" ] || {
		msg_reload 'SDKMAN'
		unset -f sdk
		. "$__sdkman_script_path"
	}

	[ -z "${LOG:-}" ] || {
		msg '⏱' 'Times:'
		cat "$LOG"
		rm "$LOG"
	}

	__color 100 240 100
	msg '✅' 'All Done.'
	printf '\x1b[0m\n'
}

# extra setup
#/usr/bin/find ~/Library -flags hidden -maxdepth 0 -exec /usr/bin/chflags nohidden "{}" +
#
#{ defaults read  com.apple.dock persistent-others | grep '"recents-tile"' >/dev/null 2>&1 ; } || \
#  defaults write com.apple.dock persistent-others -array-add '{ "tile-data" = { "list-type" = 1; }; "tile-type" = "recents-tile"; }'
#
# Enable subpixel font rendering on non-Apple LCDs
#defaults write -g AppleFontSmoothing -int 2

# Site-specific
[ ! -r "$HOME/.bash_profile.local" ] || . "$HOME/.bash_profile.local"

# ex: noet ci pi sts=0 sw=2 ts=2 filetype=sh
