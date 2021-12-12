#!/usr/bin/env bash

source shuz.sh
source settings

[[ "${SHELL}" =~ zsh ]] || fail "This script can run only in zsh shell. Current shell is ${SHELL}"

# Helper functions
#-------------------------------------------

installing() {
  ec "${green}Installing ${yellow}$1${noc}"
}

configuring() {
  ec "${green}Configuring ${yellow}$1${noc}"
}

skipping() {
  ec "${green}Skipping ${yellow}$1${noc}"
}

found() {
  ec "${green}Found ${yellow}$1${noc}"
}

# Returns 0 if an executable is NOT on PATH
missing() {
  if which $1 &>/dev/null; then
    found "$1"
    return 1
  fi

  return 0 
}

# Returns 0 if a cask is NOT installed
missing-cask() {
  if brew list --cask $1 &>/dev/null; then
    found "$1"
    return 1
  fi

  return 0 
}

# Installation functions
#-------------------------------------------

install_brew() {
  installing brew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || fail 'Failed to install brew'

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/${USER}/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

install_nordvpn() {
  [ "${nordvpn}" = "0" ] && ec "${green}Skipping ${yellow}nordvpn${noc}" && return 0

  installing nordvpn
  brew install nordvpn || fail Failed to install NordVPN
  are_you_sure 'Would you like to stop the script to activate the VPN?' && exit 0
}

install_oh_my_zsh() {
  [ -n "$ZSH" ] && found "Oh My Zsh!" && return 0
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || fail 'Failed to install Oh My Zsh!'

  # Download the non bundled zsh-autosuggestions plugin
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

  # Set the plugins list
  grep --quiet 'plugins=' $HOME/.zshrc || fail '.zshrc has unexpected structure'
  sed -i .old "s/plugins=.*/plugins=(${ohmyzsh_plugins})/g" $HOME/.zshrc || fail 'Failed to update zsh plugins'
  br
}

install_powerlevel10k() {
  powerlevel10k_dir=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

  [ -d "${powerlevel10k_dir}" ] && found powerlevel10k && return 0

  installing powerlevel10k
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${powerlevel10k_dir} || fail 'Failed to install powerlevel10k'

  grep --quiet 'ZSH_THEME=' $HOME/.zshrc || fail '.zshrc has unexpected structure'
  sed -i '' 's/ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' $HOME/.zshrc || fail 'Failed to change the zsh theme'
}

install_iterm2_profile() {
  [ "${iterm_profile}" = "0" ] && skipping "iTerm2 profile" && return 0

  profile_pathname="$HOME/Library/Application Support/iTerm2/DynamicProfiles/automagic-profile.json"
  [ -f "${profile_pathname}" ] && ec "${green}Found ${yellow}iTerm2 profile${noc}" && return 0

  configuring "iTerm2 profile"
  cp ./iterm2-profile.json "${profile_pathname}" || fail 'Failed to install iTerm2 profile'
}

# Post-install configurations
#-------------------------------------------

post_install_node() {
  missing node && echo 'export PATH="/opt/homebrew/opt/node@14/bin:$PATH"' >> ~/.zshrc && configuring node
}

post_install_pyenv() {
  [[ "$PATH" =~ pyenv ]] && found pyenv && return 0

  configuring pyenv
  pyenv install ${default_python}:latest
  python_version=$(pyenv versions --bare | grep "${default_python}")
  pyenv global ${python_version} || fail 'Failed to configure Python'

  PATH="$HOME/.local/bin:$PATH" $(pyenv root)/versions/${python_version}/bin/pip install -q -q --user pipenv

  echo 'eval "$(pyenv init --path)"' >> ~/.zprofile
  echo 'eval "$(pyenv init -)"' >> ~/.zshrc
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
}

# Installations themselves
#-------------------------------------------

missing brew && install_brew

missing-cask nordvpn && install_nordvpn

br
warn Installing from Brewfile:
brew bundle --file ./Brewfile || fail 'Failed to install from Brewfile'

br
warn Pumping up your zsh:
install_oh_my_zsh
install_powerlevel10k
install_iterm2_profile

br
warn Post installation configuration:
post_install_node
post_install_pyenv

br
success 'Done. Some changes might not be activated until the shell is restarted.'
