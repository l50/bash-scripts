#!/bin/bash
# -----------------------------------------------------------------------------
# createRailsDevEnv.sh
#
# Install all required programs and dependencies for Rails
#
# Usage: bash createRailsDevEnv.sh
#
# Jayson Grace, jayson.e.grace@gmail.com, 8/20/2015
#
# Last update 8/20/2015 by Jayson Grace, jayson.e.grace@gmail.com
# -----------------------------------------------------------------------------
installRails()
{
  curl -L https://get.rvm.io | bash -s stable --auto-dotfiles --autolibs=enable --rails  
}

configureGems()
{
  rvm gemset use global
  gem update
}

installGems()
{
  gem install bundler --no-ri --no-rdoc
  gem install nokogiri --no-ri --no-rdoc
  gem install rails --no-ri --no-rdoc
}

installRvm
configureGems
installGems
