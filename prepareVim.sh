#!/bin/bash
# -----------------------------------------------------------------------------
# prepareVim.sh
#
# Set up vim environment for puppet development
#
# Usage: bash prepareVim.sh
#
# Jayson Grace, jayson.e.grace@gmail.com, 7/26/2015
#
# Last update 8/20/2015 by Jayson Grace, jayson.e.grace@gmail.com
# -----------------------------------------------------------------------------
# Install pathogen
installPathogen() {
  mkdir -p ~/.vim/autoload ~/.vim/bundle && \
  curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
}

# Prepare the vimrc file for pathogen use
prepareVimRc() {
  cat > ~/.vimrc << __EOF__
  execute pathogen#infect()
  syntax on
  filetype plugin indent on
  set expandtab
  set shiftwidth=2
  set softtabstop=2
  set paste
__EOF__
}

# Install rodjek's puppet syntax plugin
installPuppetSyntax() {
  cd ~/.vim/bundle && \
  git clone git://github.com/rodjek/vim-puppet.git
}

# Install youcompleteme for ide-like feel
installYouCompleteMe() {
  # Ubuntu
  if [ -r /etc/lsb-release ]; then
    apt-get install -y python2.7-dev build-essential cmake
    cd ~/.vim/bundle && \
    git clone https://github.com/Valloric/YouCompleteMe.git && \
    cd YouCompleteMe && \
    git submodule update --init --recursive && \
    ./install.sh --clang-completer
    # OSX
  else
    brew install macvim
    brew install cmake
    # Add to end of zsh and bashrc
    alias vim='mvim -v'
    cd ~/.vim/bundle && \
    git clone https://github.com/Valloric/YouCompleteMe.git && \
    cd YouCompleteMe && \
    git submodule update --init --recursive && \
    ./install.sh --clang-completer
  fi
}

installJSONPlugin() {
  cd ~/.vim/bundle && \
  git clone https://github.com/elzr/vim-json.git
}

installGoPlugin() {
  cd ~/.vim/bundle && \
  git clone https://github.com/fatih/vim-go.git ~/.vim/bundle/vim-go
}

installPathogen
prepareVimRc
installPuppetSyntax
#installYouCompleteMe
installJSONPlugin
installGoPlugin
