#!/usr/bin/env bash -c /usr/bin/false

# continue on errors
set +e +u +o pipefail

# don't pollute the environment by re-sourcing this
[ -z "$BASH_PROFILE_SOURCED" ] || {
	echo >&2 error ".bash_profile is already sourced."
	return 1
}

# fix that weird thing on macOS where SHELL is wrong
# and I can't use chsh because it's a network account
# and they don't recognize Homebrew-installed shells
[ -z "$BASH" ] || export SHELL="$BASH"

# darwin or linux
declare OS="$(uname -s)"
OS="${OS,,}"

declare library="$HOME/.bash.d/library"
while IFS=$'\n' read -r; do
	. "$library/$REPLY"
done < <(ls "$library")

####################
# Base environment #
####################

PATHS=(
	# User
	"$HOME/.prefix/bin"
	"$HOME/.cargo/bin"
	"$HOME/.deno/bin"
	"$HOME/.rd/bin"

	# Previous value
	"$PATH"

	# Relative tools (insecure if not kept last)
	"./node_modules/.bin"
)

export PATH="$(join_strings : ${PATHS[*]})"

#########
# Other #
#########

# If rbenv is installed, start it (it's fast enough)
! has-command rbenv || eval "$(rbenv init -)"

[ "$OS" != 'darwin' ] || {
	# Spotlight on/off
	#
	# $1: on/off
	alias spotlight='sudo mdutil -a -i'

	# Remove the quarantine flag on downloaded stuff
	! has-command xattr || alias unquarantine='xattr -drv com.apple.quarantine'

	# Paste HTML content as markup, not plain text
	function htmlpaste() {
		osascript -e 'the clipboard as «class HTML»' | perl -ne 'print chr foreach unpack("C*",pack("H*",substr($_,11,-3)))'
	}
}

! has-command gls || alias ls='gls --color=auto --show-control-chars'
! has-command eza || alias ls='eza --icons'

# Download stuff
! has-command aria2c || alias dl='aria2c -x5 --log-level=warn --file-allocation=falloc --force-save --http-accept-gzip=true --use-head=true'

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
	# Git Status
	. "$DOTFILES_DIR/.gitstatus/gitstatus.plugin.sh"
	__jc_ps1="$PS1"
	__jc_prompt_update() {
		declare -r reset=$'\033[0m'

		# Add git status if available and relevant
		declare GITSTATUS_PROMPT=''
		gitstatus_query "$@" && [[ "$VCS_STATUS_RESULT" == ok-sync ]] && {
			declare -r clean=$'\033[38;5;076m'      # green foreground
			declare -r untracked=$'\033[38;5;014m'  # teal foreground
			declare -r modified=$'\033[38;5;011m'   # yellow foreground
			declare -r conflicted=$'\033[38;5;196m' # red foreground
			declare p

			declare where # branch name, tag or commit
			if [[ -n "$VCS_STATUS_LOCAL_BRANCH" ]]; then
				where="$VCS_STATUS_LOCAL_BRANCH"
			elif [[ -n "$VCS_STATUS_TAG" ]]; then
				p+='\['"${reset}"'\]#'
				where="$VCS_STATUS_TAG"
			else
				p+='\['"${reset}"'\]@'
				where="${VCS_STATUS_COMMIT:0:8}"
			fi

			((${#where} <= 32)) || where="${where:0:12}…${where: -12}" # truncate long branch names and tags
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
		}

		# Add conda environment if available
		declare CONDA_PROMPT=''
		[[ -z "${CONDA_PREFIX:-}" ]] || {
			declare -r pink=$'\033[38;2;255;0;255m'
			declare envname="${CONDA_PREFIX##*/}"
			[[ "$envname" == 'base' ]] || CONDA_PROMPT="${reset} ${pink}${CONDA_PREFIX##*/} ${reset}"
		}

		PS1="${CONDA_PROMPT}${__jc_ps1}${GITSTATUS_PROMPT} "
	}

	gitstatus_stop && gitstatus_start -s -1 -u -1 -c -1 -d -1

	if [[ "${__bp_imported:-}" == "defined" ]]; then
		precmd_functions+=(__jc_prompt_update)
	else
		PROMPT_COMMAND="__jc_prompt_update${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
	fi

	# Open a SHA-1 as a magnet link
	function magnetize() {
		open 'magnet:?xt=urn:btih:'"$1"
	}

	# VS.Code launcher
	# Run without GPU unless on Apple silicon
	[[ "${HOSTTYPE:-}" == "aarch64" ]] || {
		alias code="$BREW_PREFIX/bin/code --disable-gpu"
	}
}

# Site-specific
[ ! -r "$HOME/.bash_profile.local" ] || . "$HOME/.bash_profile.local"

# Keep last
export BASH_PROFILE_SOURCED=1
