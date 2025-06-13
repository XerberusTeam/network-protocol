#!/bin/bash -ex

ADDITIONAL_OPTS="--break-system-packages"

# if command -v brew &> /dev/null
# then
#     ADDITIONAL_OPTS="--break-system-packages"
# fi

if ! command -v pip &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install python3
    else
        sudo apt-get update
        sudo apt-get install -y python3-pip
    fi
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update
    sudo apt-get install -y sshpass \
      python3-venv \
      python3-dev \
      libffi-dev \
      libssl-dev
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install sshpass
fi

if ! command -v pipx &> /dev/null; then
    python3 -m pip install --user pipx $ADDITIONAL_OPTS
    python3 -m pipx ensurepath
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install ansible
else
    sudo apt-get update
    sudo apt install -y ansible-core
fi

python3 -m pipx install ansible
python3 -m pipx install ansible-core
python3 -m pipx install argcomplete
