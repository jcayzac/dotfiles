
if (( ${BASH_VERSINFO:0} >= 4 ))
then
	# .bash_profile.d exists, it's a directory, and it's traversable
	if [ -d ~/.bash_profile.d ] && [ -x ~/.bash_profile.d ]
	then
		# source all scripts, in lexical order
		declare space=''
		echo -en "\033[01;34mLoading ["
		for x in ~/.bash_profile.d/*
		do
			echo -n "${space}${x##*/????}"
			space=' '
			. "$x"
		done
		echo -e "]\033[0m"
	fi
else
	echo "ERROR: expected \$BASH_VERSINFO >= 4, but found ${BASH_VERSINFO:0}"
fi

# ex: noet ci pi sts=0 sw=4 ts=4 filetype=sh
