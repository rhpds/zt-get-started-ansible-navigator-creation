#!/bin/sh
# Validates that ansible-navigator.yml has editor configuration

if [ ! -f "/home/rhel/ansible-files/ansible-navigator.yml" ]; then
  echo "ERROR: ansible-navigator.yml does not exist"
  exit 1
fi

if ! grep -q "editor:" /home/rhel/ansible-files/ansible-navigator.yml; then
  echo "ERROR: ansible-navigator.yml missing editor configuration"
  exit 1
fi

echo "Validation passed: ansible-navigator.yml has editor configuration"
exit 0
