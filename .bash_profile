
if (( ${BASH_VERSINFO:0} >= 4 ))
then
	# .bash_profile.d exists, it's a directory, and it's traversable
	if [ -d ~/.bash_profile.d ] && [ -x ~/.bash_profile.d ]
	then
		# source all scripts, in lexical order
		for x in ~/.bash_profile.d/*
		do
			. "$x"
		done
	fi
else
	echo "ERROR: expected \$BASH_VERSINFO >= 4, but found ${BASH_VERSINFO:0}"
fi

