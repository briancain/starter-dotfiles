#! /bin/bash

# Brian Cain 2014
# Update oh-my-zsh

OMZDIR=~/.dotfiles/oh-my-zsh

if [ -d "$OMZDIR" ] ; then
  echo 'Updating oh-my-zsh to latest version'
  cd ~/.dotfiles/oh-my-zsh
  git pull origin master
  cd -
fi

echo 'Complete Update!'
