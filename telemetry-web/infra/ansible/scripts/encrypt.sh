#!/bin/bash -e

# This script encrypts a given string using ansible-vault and outputs the result
# with a specified variable name for inclusion in Ansible playbooks or variable files.

# Check if the correct number of arguments is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <variable_name>"
  exit 1
fi

# Assign the first argument to the variable name
VARIABLE_NAME=$1

# Prompt the user to enter the value to be encrypted for the given variable name
echo "Enter the value to encrypt for $VARIABLE_NAME:"
# Read the input value without showing it on the screen
read TEXT

# Encrypt the input value using ansible-vault and assign the result to the RESULT variable
RESULT=$(echo "$TEXT" | ansible-vault encrypt_string --name "$VARIABLE_NAME")

# Output the encrypted result
echo "${VARIABLE_NAME}": "${RESULT}"

# Usage Instructions:
# 1. Run the script with the variable name as an argument:
#    ./encrypt.sh <variable_name>
# 2. Enter the value to be encrypted when prompted.
# 3. Copy the output encrypted string to your Ansible playbook or variable file.
#    like this:
#    <variable_name>: !vault |
#      $ANSIBLE_VAULT;1.1;AES256
#      ...
# 4. Run your playbook with the appropriate vault password options:
#    ansible-playbook playbook.yml --ask-vault-pass
#    or
#    ansible-playbook playbook.yml --vault-password-file vault_password.txt
