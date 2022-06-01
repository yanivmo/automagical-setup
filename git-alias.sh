#!/usr/bin/env sh

# Graphical log tree
git config --global alias.lg '!git --no-pager log --graph --pretty=tformat:'\''%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cd) %C(blue)<%an>%Creset'\'' --abbrev-commit --date=default-local'

# Concise status
git config --global alias.st 'status -s -b'

# Shorter checkout
git config --global alias.co 'checkout'

# Push a new branch to the remote
git config --global alias.upload '!git push -u origin $(git symbolic-ref --short HEAD)'

# Delete local branches that were deleted from the remote
git config --global alias.fetch-prune '!git fetch --prune && git for-each-ref --format '\''%(refname:short)%09%(upstream:track)'\'' refs/heads | grep '\''\\[gone\\]'\'' | cut -f 1 | xargs git branch -v -D'
