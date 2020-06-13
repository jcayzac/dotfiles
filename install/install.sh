#!/bin/bash
set -e -u -o pipefail

export DOTFILES_URL="https://raw.githubusercontent.com/jcayzac/dotfiles/master/install"
export DOTFILES_DIR="$HOME/.dotfiles"
export LANG='en_US.UTF-8'

declare STATE_DIR="$HOME/INSTALL_STATE"
mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"
cd "$STATE_DIR"

# Setup sudo
(
	read -s -p "Enter password for sudo (1/2): " PASSWORD
	echo
	read -s -p "Enter password for sudo (2/2): " PASSWORD_AGAIN
	echo
	[[ "$PASSWORD" == "$PASSWORD_AGAIN" ]] || {
		printf "The passwords don't match!\n"
		exit 1
	}

	printf '#!/bin/bash\n'"printf '%s'"'\n' "$PASSWORD" >password-for-sudo
	chmod 700 password-for-sudo
)

do-sudo() {
	SUDO_ASKPASS="$STATE_DIR/password-for-sudo" sudo -A "${1+$@}"
}

do-sudo true || {
	printf '***Error: Wrong password\n'
	exit 1
}

# Setup decryptor
(
	read -s -p "Enter password for decrypting (1/2): " PASSWORD
	echo
	read -s -p "Enter password for decrypting (2/2): " PASSWORD_AGAIN
	echo
	[[ "$PASSWORD" == "$PASSWORD_AGAIN" ]] || {
		printf "The passwords don't match!\n"
		exit 1
	}

	printf '#!/bin/bash\nexec openssl enc -d -pass '"'pass:$PASSWORD'"' "${1+$@}"' >decryptor
	chmod 700 decryptor
)

function decrypt() {
	"$STATE_DIR/decryptor" "${1+$@}"
}

# Any AD notation in the groups means it's a work machine
if /usr/bin/id -p | grep -E ^groups | cut -d $'\t' -f2 | grep '\\' >/dev/null 2>&1
then
	declare PROFILE="work"
else
	declare PROFILE="home"
fi

delete-if-exists() {
	[ ! -e "$1" ] || {
		printf '  Deleting [%s]…\n' "$1"
		rm -rf "$1"
	}
}

download() {
	printf '  Downloading [%s]…\n' "$1"
	curl -fsSL -o "$1" "${2:-$DOTFILES_URL/$1}"
}

source-phase() {
	printf '\033[38;5;076mPhase: %s\033[0m\n' "$1"
	declare CHECKPOINT="checkpoint--${1}"
	[ -f "$CHECKPOINT" ] || {
		download "phase-${1}" "$DOTFILES_URL/${1}"
		. "phase-${1}"
		touch "$CHECKPOINT"
		printf '  \033[38;5;014mPhase [%s] completed successfully.\033[0m\n\n' "$1"
	}
}

source-phase "ssh-config"
source-phase "dotfiles"
source-phase "buildtools"
source-phase "homebrew"
source-phase "node"
source-phase "mas"
source-phase "defaults"

printf '\nCleaning up…\n'
rm -rf "$STATE_DIR"
printf '\033[38;5;014mAll Done.\033[0m\n'
