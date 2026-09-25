#!/bin/sh
# Validates that execution environment is enabled

if [ ! -f "/home/rhel/ansible-files/ansible-navigator.yml" ]; then
  echo "ERROR: ansible-navigator.yml does not exist"
  exit 1
fi

if ! grep -q "enabled: true" /home/rhel/ansible-files/ansible-navigator.yml; then
  echo "ERROR: Execution environment not enabled"
  exit 1
fi

echo "Validation passed: Execution environment is enabled"
exit 0
