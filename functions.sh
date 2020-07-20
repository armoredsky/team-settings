#!/bin/bash
pushd . > /dev/null 2>&1

# general
alias sls="source-latest-settings"

function openc {
	open ./coverage/lcov-report/index.html
}

function redo {
	 rm -rf node_modules/; rm package-lock.json; npm i 
}

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
        echo "need to fis this"
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
