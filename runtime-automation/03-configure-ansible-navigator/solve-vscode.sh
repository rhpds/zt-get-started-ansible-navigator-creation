#!/bin/sh

set -eu

tee /home/rhel/ansible-files/ansible-navigator.yaml << EOF
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

  editor:
    command: code-server {filename}
    console: false

EOF