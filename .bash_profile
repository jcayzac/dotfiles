
# Wrap everything into a function so that all declared variables are local
profile() {
	if (( ${BASH_VERSINFO:0} >= 4 ))
	then
		# .bash_profile.d exists, it's a directory, and it's traversable
		if [ -d ~/.bash_profile.d ] && [ -x ~/.bash_profile.d ]
		then
			# source all scripts, in lexical order
			declare space='' x
			printf "\x1b[01;34mLoading ["
			for x in ~/.bash_profile.d/*
			do
				printf '%s%s' "${space}" "${x##*/????}"
				space=' '
				. "$x"
			done
			printf "]\x1b[0m\n"
		fi

		# Show a palette: fixed colors 1-15, then 24-bit gray ramp
		# Shows immediately if 24-bit mode is supported.
		declare COL COLS L
		read -r COLS < <(tput cols)
		for COL in {1..15}
		do
			printf "\x1b[48;5;%sm " "$COL"
		done
		for ((COL=15; COL<COLS; ++COL))
		do
			L=$(( (255 * $COL) / $COLS ))
			printf "\x1b[48;2;$COL;$((COL/2));$((COL/3))m "
		done
		printf "\x1b[0m\n"
	else
		echo "ERROR: expected \$BASH_VERSINFO >= 4, but found ${BASH_VERSINFO:0}"
	fi
}; profile; unset profile

# ex: noet ci pi sts=0 sw=4 ts=4 filetype=sh
