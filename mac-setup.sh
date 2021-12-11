#!/usr/bin/env bash

source shuz.sh
source settings

[[ "${SHELL}" =~ zsh ]] || fail "This script can run only in zsh shell. Current shell is ${SHELL}"

# Helper functions
#-------------------------------------------

# Returns 0 if an executable is NOT on PATH
missing() {
  if which $1 &>/dev/null; then
    ec "${green}Found ${yellow}$1${noc}"
    return 1
  fi

  ec "${green}Installing ${yellow}$1${noc}"
  return 0 
}

# Returns 0 if a cask is NOT installed
missing-cask() {
  if brew list --cask $1 &>/dev/null; then
    ec "${green}Found ${yellow}$1${noc}"
    return 1
  fi

  ec "${green}Installing ${yellow}$1${noc}"
  return 0 
}

# Installation functions
#-------------------------------------------

install_brew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || fail 'Failed to install brew'

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/${USER}/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_nordvpn() {
  [ "${nordvpn}" = "0" ] && ec "${green}Skipping ${yellow}nordvpn${noc}" && return 0

  brew install nordvpn || fail Failed to install NordVPN
  are_you_sure 'Would you like to stop the script to activate the VPN?' && exit 0
}

install_oh_my_zsh() {
  [ -n "$ZSH" ] && ec "${green}Found ${yellow}Oh My Zsh!${noc}" && return 0
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || fail 'Failed to install Oh My Zsh!'

  grep --quiet 'plugins=' $HOME/.zshrc || fail '.zshrc has unexpected structure'
  sed -i .old "s/plugins=.*/plugins=(${ohmyzsh_plugins})/g" $HOME/.zshrc || fail 'Failed to update zsh plugins'
  br
}

install_powerlevel10k() {
  powerlevel10k_dir=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

  [ -d "${powerlevel10k_dir}" ] && ec "${green}Found ${yellow}powerlevel10k${noc}" && return 0

  ec "${green}Installing ${yellow}powerlevel10k${noc}"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${powerlevel10k_dir} || fail 'Failed to install powerlevel10k'

  grep --quiet 'ZSH_THEME=' $HOME/.zshrc || fail '.zshrc has unexpected structure'
  sed -i '' 's/ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' $HOME/.zshrc || fail 'Failed to change the zsh theme'
}

# Installations themselves
#-------------------------------------------

missing brew && install_brew

missing-cask nordvpn && install_nordvpn

br
warn Installing from Brewfile:
brew bundle --file ./Brewfile

br
warn Pumping up your zsh:
install_oh_my_zsh
install_powerlevel10k

br
success 'Done. Some changes might not be activated until the shell is restarted.'
