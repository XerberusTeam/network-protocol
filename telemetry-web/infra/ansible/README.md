# Ansible Monorepo for xerberus Nodes Deployment

This repository contains Ansible roles and playbooks to deploy the xerberus environemnts for the connected nodes. It provides a comprehensive setup for managing, connectivity (via cloudflared) and computation (via docker).

## Playbooks

The primary entry point is the `main.yml` playbook.

## Scripts Directory

The `./scripts` directory contains scripts that should be executed sequentially to set up and manage the deployment environment:

1. `01-dependencies.sh` - Installs the dependencies required to run Ansible and Galaxy dependencies on the local machine.
2. `02-configs.sh` - Configures the project settings.
3. `03-provision.sh` - Executes the playbook on the remote hosts as per the inventory.
4. `encrypt.sh` - A utility script for encrypting secret values with Ansible Vault.

## Project Structure

Below is the tree directory of the project, illustrating the organization of playbooks, roles, variables, and scripts.

```plaintext
.
├── ansible.cfg - Ansible configuration file
├── group_vars - Group variables
├── main.yml - Main playbook
├── requirements.yml
├── roles - Ansible roles
└── scripts - Utility scripts
```

## Getting Started

To deploy Ethereum nodes using this repository, follow these steps:

1. **Install Dependencies**: Run the `01-dependencies.sh` script to install necessary dependencies on your local machine.
2. **Configure Project**: Execute the `02-configs.sh` script to set up project configurations.
3. **Provision Nodes**: Use the `03-provision.sh` script to deploy the Ethereum nodes as defined in your inventory.
4. **Establish cloudflared connectivity**: If required, use `04-connection.sh` for SSH connection.
5. **Encrypt Secrets**: Secure your secret values using the `encrypt.sh` script with Ansible Vault for enhanced security.

## Inventory

The project uses an Ansible inventory file (`cluster.dev.ini`) located under the `group_vars/inventory` directory to manage the nodes. This file should be updated to reflect the actual hosts and their respective configurations.

Example:

```plaintext
[xerberus]
node1.host ansible_become=yes ansible_become_user=root ansible_user=foobar ansible_ssh_user=foobar ansible_ssh_pass=foo1 ansible_sudo_pass=foo1
```

## Encrypting Secrets

To encrypt secret values, use the `encrypt.sh` script with Ansible Vault. The password to use will be in the (hidden) `.vault.pwd` file (if you don't have this file ask to be provided), This password will be used to encrypt the secret values. The encrypted values will be stored in the `xerberus.yml` file.

Example:

```bash
./scripts/encrypt.sh xerberus_secret_value
Enter the value to encrypt for xerberus_secret_value:
foobar
xerberus_secret_value: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          38363664626464376138623337366636343038636134366433323533326639386665343537343432
          3363353331396333616231353634653833333564613764660a326564643362313665393233356339
          62383161643930343339613765386531326434333265613030656461663438386161353031633464
          3738636437363732620a353434363438626263363864663437636535396261666431363137303938
          3533
```

Once you have your new encrypted value, update the `xerberus.yml` file with the new value. In this case the `xerberus_secret_value` var value.

## Requirements

Before running the scripts, ensure you have Ansible and necessary dependencies installed on your local machine. The `01-dependencies.sh` script automates this process for convenience.
