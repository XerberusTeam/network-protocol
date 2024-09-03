#!/bin/bash -ex

ansible-galaxy role install geerlingguy.docker
ansible-galaxy role install geerlingguy.pip
ansible-galaxy collection install -r requirements.yml
python3 -m pip install cryptography
