#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# uninstallAnsible.sh
#
# Remove Ansible
#
# Usage: bash uninstallAnsible.sh
#
# Author: Jayson Grace, jayson.e.grace@gmail.com, 8/13/2017
# ----------------------------------------------------------------------------

rm -rf $HOME/.pyenv
sudo rm -rf /etc/ansible
ansibleBins=('ansible' 'ansible-connection' 'ansible-console' 'ansible-doc' 'ansible-galaxy' 'ansible-playbook' 'ansible-pull' 'ansible-vault')
for ((i=0; i<${#ansibleBins[*]}; i++)); do
  sudo rm /usr/local/bin/${ansibleBins[i]}
done
echo 'remove the entries from ~/.bashrc && ~/.bash_profile or ~/.zshrc'
