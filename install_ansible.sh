#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# install_ansible.sh
#
# Install ansible
#
# Usage: bash install_ansible.sh
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
ansible_directory='/etc/ansible'
ansible_config_file="$ansible_directory/ansible.cfg"
ansible_hosts="$ansible_directory/hosts"
global_roles="$ansible_directory/roles"
ansible_workspace="$HOME/.ansible/Workspace"
pyenv_installed=true
python_version='3.6.5'

##### (Cosmetic) Color output
RED="\033[01;31m"      # Issues/Errors
GREEN="\033[01;32m"    # Success
BLUE="\033[01;34m"     # Heading
RESET="\033[00m"       # Normal

install_apt_deps()
{
  echo -e "${BLUE}Making sure all apt dependencies are in place, please wait...${RESET}"
  sudo apt update
  sudo DEBIAN_FRONTEND=noninteractive apt install -y git build-essential libssl-dev libbz2-dev make zlib1g-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    tk-dev xz-utils
}

installPyenvDeps()
{
  if [[ `uname` != 'Darwin' ]]; then
    os=`cat /etc/os-release | perl -n -e'while(/^ID=(.*)/g) {print "$1\n"}'`
    if [[ $os == 'ubuntu' || $os == 'kali' ]]; then
      install_apt_deps
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

install_pyenv()
{
  installPyenvDeps
  if [[ ! -d $HOME/.pyenv ]]; then
    pyenv_installed=false
    echo -e "${BLUE}Installing pyenv, please wait...${RESET}"
    curl https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
    setDotfileParams
  else
    echo -e "${GREEN}pyenv has already been installed, moving on...${RESET}"
  fi
}

install_python()
{
  echo -e "${BLUE}Installing python ${python_version} and setting it globally using pyenv, please wait...${RESET}"
  if [[ ! -f $HOME/.pyenv/versions/$python_version/bin/python ]]; then
    $HOME/.pyenv/bin/pyenv install $python_version
    $HOME/.pyenv/bin/pyenv global $python_version
  else
    echo -e "${GREEN}Python version ${python_version} has already been installed, moving on...${RESET}"
  fi
  if [[ ! -f /usr/bin/python ]]; then
    # Symlink to fix issues with ansible
    sudo ln -s $HOME/.pyenv/versions/$python_version/bin/python /usr/bin/python
  fi
}

get_pip()
{
  if [[ $pyenv_installed == false ]]; then
    echo -e "${BLUE}Installing pip, please wait...${RESET}"
    $HOME/.pyenv/shims/easy_install pip
  fi
  echo -e "${BLUE}Making sure we are using the latest version of pip, please wait...${RESET}"
  $HOME/.pyenv/versions/$python_version/bin/pip install --upgrade pip
}

install_ansible()
{
  echo -e "${BLUE}Installing ansible, please wait...${RESET}"
  $HOME/.pyenv/versions/$python_version/bin/pip install ansible
}

create_ansible_directory()
{
  if [[ ! -d $ansible_directory ]]; then
    sudo mkdir $ansible_directory
    # This will not work on docker by default because $USER is not defined - you need to define it as an ENV var
    sudo chown $USER $ansible_directory
  else
    echo -e "${GREEN}Ansible directory already created, moving on...${RESET}"
  fi
}

get_ansible_config_file()
{
  if [[ ! -f $ansible_config_file ]]; then
    echo 'getting config file'
    curl https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg\
      -o $ansible_config_file
    sudo bash -c "echo ansible_python_interpreter = $HOME/.pyenv/versions/$python_version/bin/python >> $ansible_config_file"
  else
    echo -e "${GREEN}Ansible config file already created, moving on...${RESET}"
  fi
}

modify_ansible_config_file()
{
  if [[ -f $ansible_config_file ]]; then
    echo 'Adding logging to ansible config file'
    sed -i".old" 's/#log_path = \/var\/log\/ansible.log/log_path = \/var\/log\/ansible.log/' $ansible_config_file
  else
    echo -e "${RED}Unable to find ansible config file to modify, moving on...${RESET}"
  fi
}

create_host_file()
{
  if [[ ! -f $ansible_hosts ]]; then
    sudo touch $ansible_hosts
    # Run playbooks locally
    echo "localhost ansible_connection=local" | sudo tee $ansible_hosts
  fi
}

check_ansible_installed()
{
  if $HOME/.pyenv/versions/${python_version}/bin/ansible localhost -m ping > /dev/null; then
    echo -e "${GREEN}Ansible was successfully installed!${RESET}"
  else
    echo -e "${RED}There was an issue installing ansible.${RESET}"
  fi
}

create_ansible_workspace()
{
  if [[ ! -d $ansible_workspace ]]; then
    echo -e "${BLUE}Creating ansible workspace at $ansible_workspace ${RESET}"
    mkdir -p $ansible_workspace
  else
    echo -e "${GREEN}Ansible workspace already created, moving on...${RESET}"
  fi
}

create_global_roles()
{
  if [[ ! -d $global_roles ]]; then
    echo -e "${BLUE}Creating global ansible roles directory${RESET}"
    sudo mkdir $global_roles
    sudo chown -R root $ansible_directory
    if [[ $os == 'ubuntu' ]]; then
      sudo chgrp -R root $ansible_directory
    fi
  else
    echo -e "${GREEN}Global Ansible roles directory already created, moving on...${RESET}"
  fi
}

setup_ansible_symlinks()
{
  ansible_bins=('ansible' 'ansible-connection' 'ansible-console' 'ansible-doc' 'ansible-galaxy' 'ansible-playbook' 'ansible-pull' 'ansible-vault')
  # If there's already an ansible in place, remove it
  if [[ -f /usr/local/bin/ansible ]]; then
    sudo rm -rf /usr/local/bin/ansible
  fi

  for ((i=0; i<${#ansible_bins[*]}; i++)); do
    echo -e "${BLUE}Creating ${ansible_bins[i]} symlink${RESET}"
    sudo ln -s $HOME/.pyenv/versions/${python_version}/bin/${ansible_bins[i]} /usr/local/bin/${ansible_bins[i]}
  done
}

create_log_file()
{
  echo -e "${BLUE}Creating log file at /var/log/ansible.log${RESET}"
  sudo touch /var/log/ansible.log
  sudo chmod 644 /var/log/ansible.log
}

install_pyenv
install_python
get_pip
install_ansible
create_ansible_directory
get_ansible_config_file
modify_ansible_config_file
create_host_file
check_ansible_installed
create_ansible_workspace
create_global_roles
setup_ansible_symlinks
create_log_file
