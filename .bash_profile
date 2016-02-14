# Configuration
DEFAULT_JAVA="1.8"

# Brew formulaes:
#
# bash
# bash-completion
# bash-git-prompt
# coreutils
# findutils
# git --with-brewed-curl --with-brewed-openssl --with-pcre --with-persistent-https --with-blk-sha1
# gnu-sed
# htop --with-ncurses

# Environment
set +e +u +o pipefail
read -d '' -r USERNAME < <(/usr/bin/dscl -q . -read "$HOME" RealName)
export \
	GEM_HOME="$HOME/.gems" \
	GIT_PS1_SHOWDIRTYSTATE=1 \
	GIT_PS1_SHOWSTASHSTATE=1 \
	GIT_PS1_SHOWUNTRACKEDFILES=1 \
	GIT_PS1_SHOWUPSTREAM="verbose name" \
	GOPATH="$HOME/.go" \
	GREP_COLOR="01" \
	HISTCONTROL="erasedups" \
	HISTFILESIZE=10000 \
	HISTIGNORE="&:ls:cd:pwd:[bf]g:exit" \
	JAVA_HOME="$(/usr/libexec/java_home -v $DEFAULT_JAVA 2>/dev/null)" \
	LANG="en_US.UTF-8" \
	LESS_TERMCAP_us=$'\E[01;32m' \
	LESS_TERMCAP_ue=$'\e[0m' \
	LESS_TERMCAP_md=$'\e[01m' \
	LESS_TERMCAP_me=$'\e[0m' \
	LESS='-FXRSN~g' \
	LS_COLORS="do=01;35:*.dmg=01;31:*.aac=01;35:*.img=01;31:*.tar=01;31:di=01;34:rs=0:*.qt=01;35:ex=01;32:ow=34;42:*.mov=01;35:*.jar=01;31:or=40;31;01:*.pvr=01;35:*.ogm=01;35:*.svgz=01;35:*.toast=01;31:*.asf=01;35:*.bz2=01;31:*.rar=01;31:*.sparsebundle=01;31:*.ogg=01;35:*.m2v=01;35:*.svg=01;35:*.sparseimage=01;31:*.7z=01;31:*.mp4=01;35:*.tbz2=01;31:bd=40;33;01:*.vob=01;35:*.zip=01;31:*.avi=01;35:*.mp3=01;35:so=01;35:*.m4a=01;35:ln=01;36:*.tgz=01;31:tw=30;42:*.png=01;35:*.wmv=01;35:sg=30;43:*.rpm=01;31:*.gz=01;31:*.tbz=01;31:*.mkv=01;35:*.mpg=01;35:*.pkg=01;31:*.mpeg=01;35:*.iso=01;31:ca=30;41:pi=41;33:*.wav=01;35:su=37;41:*.jpg=01;35:st=37;44:cd=40;33;01:*.m4v=01;35:mh=01;36:" \
	MANPATH="$HOME/.prefix/share/man:/usr/share/man:/usr/local/share/man" \
	PATH="$HOME/.prefix/bin:$HOME/.gems/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/opt/go/libexec/bin:$HOME/.go/bin" \
	PS1='\[\033[01;32m\]\u\[\033[01;34m\] \w \[\033[0m' \
	USERNAME="${USERNAME#*: }"


umask 022			# default mode = 755
ulimit -S -n 10240	# raise number of open file handles
shopt -s cmdhist	# save multiline commands in history

[ -t 1 ] && {
	bind '"\e[5~": history-search-backward'	# bind PgUp
	bind '"\e[6~": history-search-forward'	# bind PgDn
}

tabs -4	# use 4sp-wide tabs

function_exists() {
	declare -f -F $1 >/dev/null
	return $?
}

# Dependencies
/usr/bin/which brew >/dev/null 2>&1     || {
	/usr/bin/ruby -e "$(/usr/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

[ -f ~/.iterm2_shell_integration.bash ] || {
	/usr/bin/curl -fsSL -o ~/.iterm2_shell_integration.bash https://iterm2.com/misc/bash_startup.in
}

[ -f /usr/local/etc/bash_completion ]   && . /usr/local/etc/bash_completion
function_exists __git_ps1 && export PS1=${PS1}'\[\033[01;33m\]$(__git_ps1 "[%s] ")\[\033[00m\]'

[ -t 1 ] && [ -f ~/.iterm2_shell_integration.bash ] && . ~/.iterm2_shell_integration.bash
# changing PS1 is impossible after iTerm2 shell integration is enabled

[ -f ~/.nvm/nvm.sh ]                    && { . ~/.nvm/nvm.sh; nvm use stable >/dev/null; }
[ -f ~/.rvm/scripts/rvm ]               && . ~/.rvm/scripts/rvm

if /usr/bin/which rbenv >/dev/null 2>&1
then
	eval "$(rbenv init -)"
fi

[ -f ~/.gitauthor ] && {
	while true
	do
		read GIT_AUTHOR_NAME
		read GIT_AUTHOR_EMAIL
		break
	done < "${HOME}/.gitauthor"

	[ -n "$GIT_AUTHOR_NAME"  ] && export GIT_AUTHOR_NAME  GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
	[ -n "$GIT_AUTHOR_EMAIL" ] && export GIT_AUTHOR_EMAIL GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
}

# aliases and custom commands

alias grep='grep --color'
which gls    >/dev/null 2>&1 && alias ls="gls --color=auto --show-control-chars"
which gnutar >/dev/null 2>&1 && alias tar='gnutar'

dl() {
	aria2c -x5 --http-accept-gzip=true --use-head=true ${1+"$@"}
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

# extra setup

/usr/bin/find ~/Library -flags hidden -maxdepth 0 -exec /usr/bin/chflags nohidden "{}" +

{ defaults read  com.apple.dock persistent-others | grep '"recents-tile"' >/dev/null 2>&1; } || \
  defaults write com.apple.dock persistent-others -array-add '{ "tile-data" = { "list-type" = 1; }; "tile-type" = "recents-tile"; }'

# ex: noet ci pi sts=0 sw=4 ts=4 filetype=sh
