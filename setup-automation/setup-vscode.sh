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
# This image's code-server rejects --vscode-option (added in 4.134.0). Keep
# config.yaml to keys it already accepts. The lab directory is passed as the
# ExecStart argument, which older code-server uses when no folder is in the URL.
printf '%s\n' \
  'bind-addr: 0.0.0.0:8080' \
  'auth: password' \
  "password: ${CODE_SERVER_PASSWORD}" \
  'cert: false' \
  'ignore-last-opened: true' \
  > "${LAB_HOME}/.config/code-server/config.yaml"
chown "${LAB_USER}:${LAB_USER}" "${LAB_HOME}/.config/code-server/config.yaml"
chmod 0600 "${LAB_HOME}/.config/code-server/config.yaml"

# User settings live under the code-server user-data dir, not config.yaml.
# terminal.integrated.cwd is the integrated terminal start directory.
install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0700 "${LAB_HOME}/.local/share/code-server/User"
printf '%s\n' \
  '{' \
  "  \"terminal.integrated.cwd\": \"${WORKSPACE}\"" \
  '}' \
  > "${LAB_HOME}/.local/share/code-server/User/settings.json"
chown "${LAB_USER}:${LAB_USER}" "${LAB_HOME}/.local/share/code-server/User/settings.json"
chmod 0644 "${LAB_HOME}/.local/share/code-server/User/settings.json"

install -d /etc/systemd/system/code-server.service.d
CODE_SERVER_BIN=$(command -v code-server)
cat > /etc/systemd/system/code-server.service.d/workspace.conf << EOF
[Service]
ExecStart=
ExecStart=${CODE_SERVER_BIN} ${WORKSPACE}
EOF

# Keep the user service alive after the provisioning connection closes.
loginctl enable-linger
systemctl daemon-reload
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
