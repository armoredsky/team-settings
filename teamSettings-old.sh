# This contains common bash aliases and functions for your amusement and enjoyment.

# Simply source this file in your ~/.bash_profile to experience the raw power:
# source <path_to_this_git_repo>/teamSettings.sh
pushd . > /dev/null 2>&1

export PATH=${PATH}:~/AppData/Roaming/npm
export WORKSPACES_ROOT=/d/workspaces/ws1

git config --global alias.sc "svn dcommit"
git config --global alias.sr "svn rebase"
git config --global alias.st "status"
git config --global alias.l "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
git config --global alias.co "checkout"
git config --global alias.unpushed "log --branches --not --remotes"
git config --global alias.pr "pull --rebase"
git config --global alias.c "commit"
git config --global merge.tool kdiff3
git config --global push.default simple

alias st='git status'
alias gp='git push'
alias gpr='gitPullRebase'
alias gdt='git difftool --no-prompt'
alias gr="moveToRepoRoot"
alias bat="buildAndTest"
alias bat-r="buildAndTest-rebuild"
alias commit="commit"
alias commit-r="commit-rebuild"
alias gap="git add -p"

alias g='git'
alias kc='knife cookbook upload'
alias ke='knife environment from file'
alias kn='knife node from file'
alias kr='knife role from file'
alias subl='start sublime_text'
alias sls="source-latest-settings"
alias subup="update-submodules"
alias super-ready="super-ready"
alias jazzy='run-jasmine'
alias linty='run-jshint'
alias chicken='checkin'
alias tofu='checkin'

alias mcii-chef="mcii-chef"

function super-ready {
	gitPullRebase
	update-submodules
	buildAndTest-rebuild
}

function gitPullRebase {
	git pull --rebase --stat
	if [ $? -ne 0 ]; then
		echo "**"
		echo "* git pull with rebase failed, if it was due to 3-way merge, you might try using just a regular git pull."
		echo "**"
	fi

	git submodule update --init
}

function gpr-all {
	pushd "${WORKSPACES_ROOT}"
	for REPO in $(ls -d ./*); do
		pushd $REPO
		if [ -d ".git" ]; then
			gpr
		fi
		popd
	done
	popd
}

function moveToRepoRoot {
	root_dir="$(git rev-parse --show-toplevel)"
	if [ $? -ne 0 ]; then
		echo "not in a git repo directory!"
		return 1
	fi
	pushd "${root_dir}"
}

function run-jasmine {
	moveToRepoRoot
	if [ $? -ne 0 ]; then
		echo "could not move to repo root!"
		return 1
	fi

	ruby build_and_test/jasmine/run_jasmine.rb
	return_code=$?
	popd
	return $return_code
}

function run-jshint {
	moveToRepoRoot
	if [ $? -ne 0 ]; then
		echo "could not move to repo root!"
		return 1
	fi

	ruby build_and_test/jshint/run_jshint.rb
	return_code=$?
	popd
	return $return_code
}

function buildAndTest {
	moveToRepoRoot
	if [ $? -ne 0 ]; then
		echo "could not move to repo root!"
		return 1
	fi

	ruby build_and_test.rb
	return_code=$?
	popd
	return $return_code
}

function buildAndTest-rebuild {
	moveToRepoRoot
	if [ $? -ne 0 ]; then
		echo "could not move to repo root!"
		return 1
	fi

	ruby build_db.rb
	if [ $? -ne 0 ]; then
		return 1
	fi
	ruby build_and_test.rb
	return_code=$?
	popd
	return $return_code
}

function commit {
	moveToRepoRoot

	git submodule foreach git checkout master
	git submodule foreach git pull

	git add -A

	mcii

	gpr
	if [ $? -ne 0 ]; then
		echo "git pull failed"
		popd
		return 1
	fi

	buildAndTest
	if [ $? -ne 0 ]; then
		echo "build_and_test failed"
		popd
		return 1
	fi

	gp
	if [ $? -ne 0 ]; then
		echo "git push failed"
		popd
		return 1
	fi

	popd
}

function commit-rebuild {
	moveToRepoRoot

	git submodule foreach git checkout master
	git submodule foreach git pull

	git add -A

	mcii

	gpr
	if [ $? -ne 0 ]; then
		echo "git pull failed"
		popd
		return 1
	fi

	buildAndTest-rebuild
	if [ $? -ne 0 ]; then
		echo "build_and_test failed"
		popd
		return 1
	fi

	gp
	if [ $? -ne 0 ]; then
		echo "git push failed"
		popd
		return 1
	fi

	popd
}

function clone {
	git clone ssh://git@prod-stash01:7999/core/$1.git
}

function source-latest-settings {
	curl --user NOPEdev:m0b1d3v! "http://prod-stash01:7990/projects/CORE/repos/NOPE-tools/browse/script/dev_setup/teamSettings.sh?at=HEAD&raw" > ~/teamSettings.sh && source ~/teamSettings.sh
}

function update-submodules {
	moveToRepoRoot

  git submodule foreach git checkout master
  git submodule foreach git pull

  popd
}

function up-cookbook-version {
	echo "updating version in metadata.rb"

	new_version=$(($(cat metadata.rb | grep version |\
	 sed -r -e "s=^.*'(.*)'.*$=\1=g" -e "s=^.*([0-9]+)$=\1=g") + 1))

	base_line_for_replace=$(cat metadata.rb | grep version |\
	 sed -r -e "s=(^.*)[0-9]+'$=\1=" -e "s=[ \t]+=[ \t]+=g" -e "s=\.=\\\\.=g")

	sed -ri "s=(${base_line_for_replace}).*=\1${new_version}'=" metadata.rb
	if [ $? -ne 0 ]; then
		echo "up-cookbook-version failed"
		popd
		return 1
	fi

	git add metadata.rb
}

function berks-upload-cookbook {
	echo "berks uploading cookbook"
	berks upload --force
	if [ $? -ne 0 ]; then
		echo "berks-upload-cookbook failed"
		popd
		return 1
	fi
}

function mcii-chef {
		moveToRepoRoot
		up-cookbook-version
		if [ $? -ne 0 ]; then
			popd
			return 1
		fi
		berks-upload-cookbook
		if [ $? -ne 0 ]; then
			popd
			return 1
		fi
		mcii
		popd
}

function NOPEshare-old {
    if [ -z "$1" ]; then
		echo "usage: NOPEshare-old [username]"
		return 1
	fi
	username=$1
	cmd //C "net use * \\\\NOPE-share01\\$username$ /user:PTSCORP\\$username /p:no"
}

function NOPEshare {
    if [ -z "$1" ]; then
		echo "usage: NOPEshare [username]"
		return 1
	fi
	username=$1
	cmd //C "net use * \\\\df-infra-flp01\\$username$ /user:NOPE\\$username /p:no"
}

function knife() {
	/c/opscode/chefdk/bin/knife "$@" -c "/d/workspaces/ws1/tool-chef-repo/.chef/knife.rb"
}

function ssh-iqa() {
	ssh NOPE@iqa-beast01 -i /d/workspaces/ws1/tool-chef-repo/.chef/rsa/NOPE_dev_id_iqa_rsa
}


function ssh-prep() {
	if [[ -z "$1" ]] ; then
		echo "host not specified!!"
		return 1
	fi

	host=$1

	ssh NOPE@df-prep${host}a-beast01 -i /d/workspaces/ws1/tool-chef-repo/.chef/rsa/NOPE_dev_id_rsa
}

function register-ruby {
    if [ -z $1 ]
        then
            echo "Please specify a path to a ruby install."
            return 1
    fi

    if [ -z $2 ]
        then
            echo "Please specify a tag name for this ruby install."
            return 1
    fi


    declare rubypath=$1

    declare i="$((${#rubypath}-1))"
    declare lastchar="${rubypath:$i:1}"

    if [ "$lastchar" == "/" ]
        then
            rubypath="${rubypath:0:i}"
    fi

    mkdir -p ~/.rash || {
        echo "You don't deserve to be using ruby since you don't have permission to create the .rash directory"
        return 2
    }

    echo "$2,$rubypath" >> ~/.rash/rubyversions.csv
    sort -u ~/.rash/rubyversions.csv -o ~/.rash/rubyversions.csv

    echo "^$rubypath$" >> ~/.rash/rubypaths.csv
    echo "^$rubypath/$" >> ~/.rash/rubypaths.csv
    sort -u ~/.rash/rubypaths.csv -o ~/.rash/rubypaths.csv
}

function switch-ruby {
    declare rubyversion=$(<.ruby-version)
    declare rubypath=$(grep ^$rubyversion, ~/.rash/rubyversions.csv | cut -d \, -f 2)
    if [ -z $rubypath ]; then
        echo "The version of ruby found in .ruby-version does not match a registered ruby. Please register known ruby installs before using this command."
    else
        declare gemset_name=$(cat .ruby-gemset 2>/dev/null | sed 's/ *$//; s/^ *//;')
        declare rash_path="$rubypath:$(echo $PATH | tr ':' '\n' | grep -vf ~/.rash/rubypaths.csv | grep -v '/\.rash/' | tr '\n' ':' | sed 's/:$//')"
        declare tmp_gem_home

        if  [ -z "$gemset_name" ]; then
            tmp_gem_home="$HOME/.rash/$rubyversion"
            mkdir -p "$tmp_gem_home" && {
                export GEM_HOME="$tmp_gem_home" PATH="$tmp_gem_home/bin:$rash_path" GEM_PATH="$tmp_gem_home"
                echo "Switched to $rubyversion located at $rubypath with the default gem set"
            }
        else
            tmp_gem_home="$HOME/.rash/$rubyversion@$gemset_name"
            mkdir -p "$tmp_gem_home" && {
                export GEM_HOME="$tmp_gem_home" PATH="$tmp_gem_home/bin:$rash_path" GEM_PATH="$tmp_gem_home"
                echo "Switched to $rubyversion located at $rubypath with the '$gemset_name' gem set"
            }
        fi

    fi
}

function switch-java {
	JAVA_PATH_DELETE="$(cd "$JAVA_HOME/bin" ; pwd)"

	if [ "$1" == "7" ]; then
	    export JAVA_HOME=$JAVA17HOME
	elif [ "$1" == "6" ]; then
	    export JAVA_HOME=$JAVA16HOME
	elif [ "$JAVA_HOME" == "$JAVA17HOME" ]; then
	    export JAVA_HOME=$JAVA16HOME
	else
	    export JAVA_HOME=$JAVA17HOME
	fi
	echo "using \$JAVA_HOME - $JAVA_HOME"

	JAVA_PATH_ADD="$(cd "$JAVA_HOME/bin" ; pwd)"

	PATH=$( echo $PATH | sed 's|'$JAVA_PATH_DELETE'|'$JAVA_PATH_ADD'|g' )
	echo "\$PATH using - $JAVA_PATH_ADD"
}


function checkin {
	if [ ! -f $HOME/.lastcheckin ]; then
		echo "pair=pairUnknown;ticket=0000;message=;" > $HOME/.lastcheckin
		source $HOME/.lastcheckin
	else
		source $HOME/.lastcheckin
		echo Last checkin:
		echo "${pair} - NOPE-${ticket} - ${message}"
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

	git commit -m  "${pair} - NOPE-${ticket} - ${message}"
}


if [ "$PWD" == "$HOME" ]; then
	cd "${WORKSPACES_ROOT}"
else
	popd > /dev/null 2>&1
fi
