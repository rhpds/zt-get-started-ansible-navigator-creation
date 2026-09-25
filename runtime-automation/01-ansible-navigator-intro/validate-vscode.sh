#!/bin/sh
# Validates that test.yml playbook was created

if [ ! -f "/home/rhel/ansible-files/test.yml" ]; then
  echo "ERROR: The 'test.yml' playbook does not exist."
  exit 1
fi

echo "Validation passed: test.yml exists"
exit 0
