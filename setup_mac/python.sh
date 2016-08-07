#!/bin/bash
#
# All the python things

if [ ! -f "$(which pip)" ]; then
  echo "Installing pip..."
  curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | sudo python2.7
else
  echo "Looks like pip is already installed."
  if [[ "$(pip list -o 2>&1)" == *You\ should\ consider\ upgrading\ via\ the* ]]; then
    echo "Looks like pip needs an upgrade. Doing that now."
    pip install --upgrade pip
  fi
fi
echo ""

pip_install_or_upgrade() {
  if [ -f "pip list | grep ${1}" ]; then
    echo "Installing ${1}..."
    pip install "$1"
  else
    echo "Looks like ${1} is already installed. Attempting upgrade."
    pip install --upgrade "$1"
  fi
}

pip_install_or_upgrade psutil
pip_install_or_upgrade powerline-status
