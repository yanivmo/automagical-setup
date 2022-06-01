#!/usr/bin/env sh

# Use vim as the default editor
git config --global core.editor 'vim'

# Disable output pagination
git config --global core.pager 'cat'

# Pulls never create extra commits and are always fast-forward only
git config --global pull.ff 'only'
