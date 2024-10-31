# Ansible Role: Xerberus

An Ansible role that facilitates deployment of xerberus node of clients.
Its objective is to enable a consistent way of deploying and upgrading the xerberus nodes.

## Example playbook

Sample Playbook:

```yaml
---
- name: Deploy xerberus stack
  hosts: all
  become: true
```
