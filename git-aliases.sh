alias amend="git commit --amend --no-edit"
alias st="git status"


function checkin {
	if [ ! -f $HOME/.lastcheckin ]; then
		echo "pair=pairUnknown;ticket=0000;message=;" > $HOME/.lastcheckin
		source $HOME/.lastcheckin
	else
		source $HOME/.lastcheckin
		echo Last checkin:
		echo "${pair} - FAW-${ticket} - ${message}"
		echo
	fi

	read -r -e -p "Pair names (separated with '/') [$pair]: " newpair
	read -r -e -p "Story number [$ticket]: " newticket
	read -r -e -p "Enter message: " message

	if [ "${newpair}" != "" ]; then
		export pair=$newpair
	fi
	if [ "${newticket}" != "" ]; then
		export ticket=$newticket
	fi

	echo "pair='$pair';ticket='$ticket';message='$message';" > $HOME/.lastcheckin
	#cat $HOME/.lastcheckin

	git commit -m  "${pair}: ${ticket} - ${message}"
}

