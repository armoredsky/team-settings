# This contains common bash aliases and functions for your amusement and enjoyment.

# Simply source this file in your ~/.bash_profile to experience the raw power:
# source <path_to_this_git_repo>/teamSettings.sh
pushd . > /dev/null 2>&1

git config --global alias.st "status"
git config --global alias.l "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
git config --global alias.co "checkout"
git config --global alias.unpushed "log --branches --not --remotes"
git config --global alias.pr "pull --rebase"
git config --global alias.c "commit"

git config --global merge.tool kdiff3
git config --global push.default simple

alias gp='git push'
alias gpr='git pull --rebase --stat'
alias st='git status'

# general
alias sls="source-latest-settings"



function moveToRepoRoot {
	root_dir="$(git rev-parse --show-toplevel)"
	if [ $? -ne 0 ]; then
		echo "not in a git repo directory!"
		return 1
	fi
	pushd "${root_dir}"
}


function buildAndTest {
	moveToRepoRoot
	if [ $? -ne 0 ]; then
		echo "could not move to repo root!"
		return 1
	fi

	sh ./build_and_test.sh
	return_code=$?
	popd
	return $return_code
}

function source-latest-settings {
#todo: fix this
	# curl --user mobidev:m0b1d3v! "http://prod-stash01:7990/projects/CORE/repos/mobi-tools/browse/script/dev_setup/teamSettings.sh?at=HEAD&raw" > ~/teamSettings.sh && source ~/teamSettings.sh
}


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

	git commit -m  "${pair} - FAW-${ticket} - ${message}"
}


if [ "$PWD" == "$HOME" ]; then
	cd "${WORKSPACES_ROOT}"
else
	popd > /dev/null 2>&1
fi