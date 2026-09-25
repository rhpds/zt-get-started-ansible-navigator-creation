#!/bin/sh
# This script validates the vscode environment setup.
set -eu

LAB_USER="rhel"
LAB_HOME="/home/${LAB_USER}"
WORKSPACE="${LAB_HOME}/ansible-files"

echo "Validating workspace directory..."
if [ ! -d "${WORKSPACE}" ]; then
  echo "ERROR: Workspace directory ${WORKSPACE} does not exist"
  exit 1
fi

if [ "$(stat -c '%U' "${WORKSPACE}")" != "${LAB_USER}" ]; then
  echo "ERROR: Workspace directory is not owned by ${LAB_USER}"
  exit 1
fi

echo "Validating code-server installation..."
if ! command -v code-server >/dev/null 2>&1; then
  echo "ERROR: code-server is not installed"
  exit 1
fi

echo "Validating code-server configuration..."
if [ ! -f "${LAB_HOME}/.config/code-server/config.yaml" ]; then
  echo "ERROR: code-server config file not found"
  exit 1
fi

echo "Validating code-server service..."
if ! systemctl is-active --quiet code-server; then
  echo "ERROR: code-server service is not running"
  systemctl status code-server --no-pager || true
  exit 1
fi

if ! systemctl is-enabled --quiet code-server; then
  echo "WARNING: code-server service is not enabled"
fi

echo "Validating code-server port..."
if ! netstat -tuln | grep -q ':8080.*LISTEN' 2>/dev/null; then
  if ! ss -tuln | grep -q ':8080.*LISTEN' 2>/dev/null; then
    echo "ERROR: code-server is not listening on port 8080"
    exit 1
  fi
fi

echo "Validating ansible-navigator.yml..."
if [ ! -f "${WORKSPACE}/ansible-navigator.yml" ]; then
  echo "ERROR: ansible-navigator.yml not found in ${WORKSPACE}"
  exit 1
fi

echo "✓ All validations passed"
echo "✓ Workspace: ${WORKSPACE}"
echo "✓ code-server: running and listening on TCP/8080"
echo "✓ ansible-navigator.yml: present"
exit 0
