#!/bin/sh
# This script runs as root on vscode during lab provisioning.
set -eu

LAB_USER="rhel"
LAB_HOME="/home/${LAB_USER}"
WORKSPACE="${LAB_HOME}/ansible-files"
CODE_SERVER_PASSWORD="${CODE_SERVER_PASSWORD:-ansible123!}"

echo "Creating the Ansible learner workspace"
install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0755 "${WORKSPACE}"

if ! command -v code-server >/dev/null 2>&1; then
  echo "code-server not found, but devtools-ansible image should have it pre-installed!"
  exit 1
fi

echo "Configuring code-server for ${LAB_USER}"
install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0700 "${LAB_HOME}/.config/code-server"
printf '%s\n' \
  'bind-addr: 0.0.0.0:8080' \
  'auth: password' \
  "password: ${CODE_SERVER_PASSWORD}" \
  'cert: false' \
  > "${LAB_HOME}/.config/code-server/config.yaml"
chown "${LAB_USER}:${LAB_USER}" "${LAB_HOME}/.config/code-server/config.yaml"
chmod 0600 "${LAB_HOME}/.config/code-server/config.yaml"

# Keep the user service alive after the provisioning connection closes.
loginctl enable-linger
systemctl enable --now code-server
systemctl restart code-server
systemctl --no-pager --full status code-server

echo "code-server is listening on vscode TCP/8080 with ${WORKSPACE} ready to open."
echo "A CNV route is required before the Showroom browser tab can reach it."

tee /home/rhel/ansible-files/ansible-navigator.yml << EOF
---
ansible-navigator:
  execution-environment:
    container-engine: podman
    enabled: false
    image: quay.io/acme_corp/first_playbook_ee:latest
    pull:
      policy: missing

  logging:
    level: debug

  playbook-artifact:
    save-as: /home/rhel/ansible-files/{playbook_name}-artifact-{time_stamp}.json

EOF
