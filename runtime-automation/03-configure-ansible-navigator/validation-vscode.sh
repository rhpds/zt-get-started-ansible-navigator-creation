#!/bin/sh
# Validates that ansible-navigator.yml has editor configuration

set -eu

if [ ! -f "/home/rhel/ansible-files/ansible-navigator.yml" ]; then
  echo "ERROR: ansible-navigator.yml does not exist"
  exit 1
fi

if ! grep -Fq "editor:" /home/rhel/ansible-files/ansible-navigator.yml; then
  echo "ERROR: The 'ansible-navigator.yml' does not have all the contents (missing editor configuration)"
  exit 1
fi

echo "✓ Validation passed: ansible-navigator.yml has editor configuration"
exit 0
