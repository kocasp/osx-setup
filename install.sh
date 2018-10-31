#!/bin/bash

# install Xcode Command Line Tools
# https://github.com/timsutton/osx-vm-templates/blob/ce8df8a7468faa7c5312444ece1b977c1b2f77a4/scripts/xcode-cli-tools.sh
touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
PROD=$(softwareupdate -l |
  grep "\*.*Command Line" |
  head -n 1 | awk -F"*" '{print $2}' |
  sed -e 's/^ *//' |
  tr -d '\n')
softwareupdate -i "$PROD";

# --------------------
# SETUP HOMEBREW
# --------------------
# install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null 2> /dev/null

# --------------------
# SETUP ANSIBLE
# --------------------
# install ansible
brew install ansible

# setup inventory to localhost
cat >> /Users/$USER/inventory.ini <<EOL

localhost ansible_connection=local§
EOL

# setup ansible config to read inventory file
cat >> /Users/$USER/ansible.cfg <<EOL

[defaults]
hostfile = /Users/$USER/inventory.ini
EOL

# --------------------
# INSTALL APPS VIA BREW
# --------------------
# run ansible playbook
ansible-playbook main.yml

# --------------------
# SETUP OS X CONFIG
# --------------------
source osx-setup.sh
