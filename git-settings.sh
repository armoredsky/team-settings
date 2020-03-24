git config --global core.excludesfile ~/team-settings/.gitignore_global
git config --global merge.tool kdiff3
git config --global push.default simple

# git aliases
git config --global alias.st "status"
git config --global alias.l "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
git config --global alias.co "checkout"
git config --global alias.unpushed "log --branches --not --remotes"
git config --global alias.pr "pull --rebase --stat"
git config --global alias.c "commit"
git config --global alias.amend "commit --amend --no-edit"

# terminal aliases
alias st='git st'
alias amend="git amend"
