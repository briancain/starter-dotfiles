#! /bin/bash

# Author: Brian Cain
# Installs your dotfiles

# Function to determine package manager
function os_type() {
  which yum > /dev/null && {
    echo "yum"
    export OSPACKMAN="yum"
    return;
  }
  which apt-get > /dev/null && {
    echo "apt-get"
    export OSPACKMAN="aptget"
    return;
  }
  which brew > /dev/null && {
    echo "homebrew"
    export OSPACKMAN="homebrew"
    return;
  }
}

function setup_bash() {
  echo 'setup bash'
}

function setup_zsh() {
  echo 'Adding oh-my-zsh to dotfiles...'
  git clone https://www.github.com/robbyrussell/oh-my-zsh.git
}

function determine_shell() {
  echo 'Please pick your favorite shell:'
  echo '(1) Bash'
  echo '(2) Zsh'
  read -p 'Enter a number: ' SHELL_CHOICE
  if [[ $SHELL_CHOICE == '1' ]] ; then
    export LOGIN_SHELL="bash"
  elif [[ $SHELL_CHOICE == '2' ]] ; then
    export LOGIN_SHELL="zsh"
  else
    echo 'Could not determine choice.'
    exit 1
  fi
}

function setup_vim() {
  echo "Setting up vim...ignore any vim errors post install"
  vim +BundleInstall +qall
}

function setup_git() {
  echo 'Setting up git config...'
  read -p 'Enter Github username: ' GIT_USER
  git config --global user.name "$GIT_USER"
  read -p 'Enter email: ' GIT_EMAIL
  git config --global user.email $GIT_EMAIL
  git config --global core.editor vim
  git config --global color.ui true
  git config --global color.diff auto
  git config --global color.status auto
  git config --global color.branch auto
}

function symlink_files() {
  ln -s ~/.dotfiles/vimrc ~/.vimrc
  ln -s ~/.dotfiles/zshrc ~/.zshrc
  ln -s ~/.dotfiles/oh-my-zsh ~/.oh-my-zsh
}

set -e
(
  os_type
  # general package array
  declare -a packages=('vim' 'git' 'tree' 'htop' 'wget' 'curl')

  determine_shell
  if [[ $LOGIN_SHELL == 'bash' ]] ; then
    setup_bash
    packages=(${packages[@]} 'bash')
  elif [[ $LOGIN_SHELL == 'zsh' ]] ; then
    setup_zsh
    packages=(${packages[@]} 'zsh')
  fi

  if [[ $OSPACKMAN == "homebrew" ]]; then
    echo "You are running homebrew."
    echo "Using Homebrew to install packages..."
    brew update
    declare -a macpackages=('findutils' 'macvim' 'the_silver_searcher')
    brew install "${packages[@]}" "${macpackages[@]}"
    brew cleanup
  elif [[ "$OSPACKMAN" == "yum" ]]; then
    echo "You are running yum."
    echo "Using apt-get to install packages...."
    sudo yum update
    sudo yum install "${packages[@]}"
  elif [[ "$OSPACKMAN" == "aptget" ]]; then
    echo "You are running apt-get"
    echo "Using apt-get to install packages...."
    sudo apt-get update
    sudo apt-get install "${packages[@]}"
  else
    echo "Could not determine OS. Exiting..."
    exit 1
  fi

  setup_git
  symlink_files
  setup_vim

  if [[ $LOGIN_SHELL == 'bash' ]] ; then
    echo 'bash'
  elif [[ $LOGIN_SHELL == 'zsh' ]] ; then
    echo "Changing shells to ZSH"
    chsh -s /bin/zsh

    echo "Operating System setup complete."
    echo "Reloading session"
    exec zsh
  fi

)
