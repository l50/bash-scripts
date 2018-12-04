#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# installAnsible.sh
#
# Install Ansible
#
# Usage: bash installAnsible.sh
#
# Author: Jayson Grace, jayson.e.grace@gmail.com, 8/2/2017
#
# Resources:
# https://stackoverflow.com/questions/19622198/what-does-set-e-mean-in-a-bash-script/34381499
# http://binarynature.blogspot.com.au/2016/01/install-ansible-on-os-x-el-capitan_30.html
# http://ansible.pickle.io/post/86598332429/running-ansible-playbook-in-localhost
# https://unix.stackexchange.com/questions/306111/confused-about-operators-vs-vs-vs
# https://unix.stackexchange.com/questions/32210/single-or-double-brackets
# https://github.com/g0tmi1k/os-scripts/blob/master/kali-rolling.sh
# ----------------------------------------------------------------------------

# Stop execution of script if an error occurs
set -e

os=''
ansibleDirectory='/etc/ansible'
ansibleConfigFile="$ansibleDirectory/ansible.cfg"
ansibleHosts="$ansibleDirectory/hosts"
globalRoles="$ansibleDirectory/roles"
ansibleWorkspace="$HOME/.ansible/Workspace"
pyenvInstalled=true
pythonVersion='3.6.5'

##### (Cosmetic) Color output
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
YELLOW="\033[01;33m"   # Warnings/Information
BLUE="\033[01;34m"     # Heading
BOLD="\033[01;01m"     # Highlight
RESET="\033[00m"       # Normal

installAptDeps()
{
  echo -e "${BLUE}Making sure all apt dependencies are in place, please wait...${RESET}"
  sudo apt update
  sudo apt install -y git build-essential libssl-dev libbz2-dev make zlib1g-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    tk-dev xz-utils
}

installPyenvDeps()
{
  if [[ `uname` != 'Darwin' ]]; then
    os=`cat /etc/os-release | perl -n -e'while(/^ID=(.*)/g) {print "$1\n"}'`
    if [[ $os == 'ubuntu' || $os == 'kali' ]]; then
      installAptDeps
    fi
  fi
}

setDotfileParams()
{
  dotfile=''
  if [[ $(echo $SHELL) == '/bin/bash' ]]; then
    dotfile="$HOME/.bash_profile"
    echo "source $HOME/.bash_profile" >> "$HOME/.bashrc"
    if [[ ! -f $dotfile ]]; then
      touch $dotfile
    fi
  elif [[ $(echo $SHELL) == '/bin/zsh' ]]; then
    dotfile="$HOME/.zshrc"
  else
    echo 'Unsupported shell detected, please use bash or zsh.'
  fi

  if [[ ! $dotfile == '' ]]; then
    if ! grep -Fxq 'export PATH=$PATH:$HOME/.pyenv/bin' "$dotfile"; then
      echo -e "${BLUE}${dotfile} does not have pyenv vars, setting it up...${RESET}"
      echo 'export PATH=$PATH:$HOME/.pyenv/bin' >> $dotfile
      echo 'eval "$(pyenv init -)"' >> $dotfile
      echo 'eval "$(pyenv virtualenv-init -)"' >> $dotfile
    fi
  fi
}

installPyenv()
{
  installPyenvDeps
  if [[ ! -d $HOME/.pyenv ]]; then
    pyenvInstalled=false
    echo -e "${BLUE}Installing pyenv, please wait...${RESET}"
    curl https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
    setDotfileParams
  else
    echo -e "${GREEN}pyenv has already been installed, moving on...${RESET}"
  fi
}

installPython()
{
  echo -e "${BLUE}Installing Python ${pythonVersion} and setting it globally using pyenv, please wait...${RESET}"
  if [[ ! -f $HOME/.pyenv/versions/$pythonVersion/bin/python ]]; then
    $HOME/.pyenv/bin/pyenv install $pythonVersion
    $HOME/.pyenv/bin/pyenv global $pythonVersion
  else
    echo -e "${GREEN}Python version ${pythonVersion} has already been installed, moving on...${RESET}"
  fi
  if [[ ! -f /usr/bin/python ]]; then
    # Symlink to fix issues with ansible
    sudo ln -s $HOME/.pyenv/versions/$pythonVersion/bin/python /usr/bin/python
  fi
}

getPip()
{
  if [[ $pyenvInstalled == false ]]; then
    echo -e "${BLUE}Installing pip, please wait...${RESET}"
    $HOME/.pyenv/shims/easy_install pip
  fi
  echo -e "${BLUE}Making sure we are using the latest version of pip, please wait...${RESET}"
  $HOME/.pyenv/versions/$pythonVersion/bin/pip install --upgrade pip
}

installAnsible()
{
  echo -e "${BLUE}Installing Ansible, please wait...${RESET}"
  $HOME/.pyenv/versions/$pythonVersion/bin/pip install ansible
}

createAnsibleDirectory()
{
  if [[ ! -d $ansibleDirectory ]]; then
    sudo mkdir $ansibleDirectory
    # This will not work on docker because $USER is not defined
    sudo chown $USER $ansibleDirectory
  else
    echo -e "${GREEN}Ansible directory already created, moving on...${RESET}"
  fi
}

getAnsibleConfigFile()
{
  if [[ ! -f $ansibleConfigFile ]]; then
    echo 'getting config file'
    curl https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg\
      -o $ansibleConfigFile
    sudo bash -c "echo ansible_python_interpreter = $HOME/.pyenv/versions/$pythonVersion/bin/python >> $ansibleConfigFile"
  else
    echo -e "${GREEN}Ansible config file already created, moving on...${RESET}"
  fi
}

createHostFile()
{
  if [[ ! -f $ansibleHosts ]]; then
    sudo touch $ansibleHosts
    # Run playbooks locally
    echo "localhost ansible_connection=local" | sudo tee $ansibleHosts
  fi
}

checkAnsibleInstalled()
{
  if $HOME/.pyenv/versions/${pythonVersion}/bin/ansible localhost -m ping > /dev/null; then
    echo -e "${GREEN}Ansible was successfully installed!${RESET}"
  else
    echo -e "${RED}There was an issue installing Ansible.${RESET}"
  fi
}

createAnsibleWorkspace()
{
  if [[ ! -d $ansibleWorkspace ]]; then
    echo -e "${BLUE}Creating Ansible workspace at $ansibleWorkspace ${RESET}"
    mkdir -p $ansibleWorkspace
  else
    echo -e "${GREEN}Ansible workspace already created, moving on...${RESET}"
  fi
}

createGlobalRoles()
{
  if [[ ! -d $globalRoles ]]; then
    sudo mkdir $globalRoles
    sudo chown -R root $ansibleDirectory
    if [[ $os == 'ubuntu' ]]; then
      sudo chgrp -R root $ansibleDirectory
    fi
  else
    echo -e "${GREEN}Global Ansible roles directory already created, moving on...${RESET}"
  fi
}

setupAnsibleSymlinks()
{
  ansibleBins=('ansible' 'ansible-connection' 'ansible-console' 'ansible-doc' 'ansible-galaxy' 'ansible-playbook' 'ansible-pull' 'ansible-vault')
  # If there's already an ansible in place, remove it
  if [[ -f /usr/local/bin/ansible ]]; then
    sudo rm -rf /usr/local/bin/ansible
  fi

  for ((i=0; i<${#ansibleBins[*]}; i++)); do
    sudo ln -s $HOME/.pyenv/versions/${pythonVersion}/bin/${ansibleBins[i]} /usr/local/bin/${ansibleBins[i]}
  done
}

installPyenv
installPython
getPip
installAnsible
createAnsibleDirectory
getAnsibleConfigFile
createHostFile
checkAnsibleInstalled
createAnsibleWorkspace
createGlobalRoles
setupAnsibleSymlinks
