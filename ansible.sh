#!/bin/sh
ansible-playbook ./ansible/main.yml --ask-vault-pass --ask-become-pass
