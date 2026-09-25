#!/bin/sh
# Validates that ansible-navigator.yml has execution environment enabled

set -eu

if [ ! -f "/home/rhel/ansible-files/ansible-navigator.yml" ]; then
  echo "ERROR: ansible-navigator.yml does not exist"
  exit 1
fi

if ! grep -Fq "enabled: true" /home/rhel/ansible-files/ansible-navigator.yml; then
  echo "ERROR: Execution environment is not enabled in ansible-navigator.yml"
  exit 1
fi

echo "✓ Validation passed: Execution environment is enabled"
exit 0
