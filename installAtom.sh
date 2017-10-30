#!/bin/bash
# -----------------------------------------------------------------------------
# installAtom.sh
#
# Set up atom text editor on Mac OSX
#
# Usage: bash installAtom.sh
#
# Jayson Grace, jayson.e.grace@gmail.com, 8/1/2015
#
# Last update 8/20/2015 by Jayson Grace, jayson.e.grace@gmail.com
# ----------------------------------------------------------------------------

downloadAtom()
{
  wget https://github.com/atom/atom/releases/download/v1.0.7/atom-mac.zip -O ~/Downloads/atom-mac.zip
}

installAtom()
{
  cd ~/Downloads
  unzip atom-mac.zip
  mv ~/Downloads/Atom.app /Applications
}

symlink()
{
  ln -s /Applications/Atom.app/Contents/Resources/app/atom.sh /usr/local/bin/atom
}

installPlugins()
{
  # Vim bindings
  apm install vim-mode
  # Run scripts in Atom
  apm install script
  # Allow for auto indent of code
  apm install auto-indent
  # Install puppet syntax
  apm install language-puppet
}

downloadAtom
installAtom
symlink
installPlugins
