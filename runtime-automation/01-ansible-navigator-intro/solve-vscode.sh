#!/bin/sh

set -eu

tee /home/rhel/ansible-files/test.yaml  << EOF
---
- name: this is just a test
  hosts: localhost
  gather_facts: true
  tasks:

  - name: ping test
    ping:

EOF
