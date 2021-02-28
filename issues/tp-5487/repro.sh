#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

ssh-keygen -C CA -f ca -b 2048 -q -N ""

ssh-keygen -f id_rsa -b 2048 -q -N ""
ssh-keygen -s ca -I user_key -n $USERNAME -V +52w id_rsa
ssh-keygen -L -f id_rsa-cert.pub

ssh-keygen -f host_id_rsa -b 2048 -q -N ""
ssh-keygen -s ca -I host_key -h host_id_rsa
ssh-keygen -L -f host_id_rsa-cert.pub 

eval `ssh-agent -s`
ssh-add -D
ssh-add id_rsa
ssh-add -L 

gpg-connect-agent 'getinfo version' /bye
# ouch gpg stores key in cache that persists across reboots
# needs to be clean out manually with:
# gpg-connect-agent 'keyinfo --list' /bye
# gpg-connect-agent 'delete_key ...;
# possibly (arg!) gpg --delete-secret-keys  FB5638933DF2C76365DD3DEBF300F05914337732
# possibly (arg!) gpg --delete-keys  FB5638933DF2C76365DD3DEBF300F05914337732
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
ssh-add -D
ssh-add id_rsa
ssh-add -L 




# debugging commands
# systemctl --user stop gpg-agent gpg-agent-ssh.socket gpg-agent.socket gpg-agent-browser.socket gpg-agent-extra.socket
# ./gpg-agent --verbose --verbose   --enable-ssh-support  --daemon --no-detach --enable-extended-key-format
# export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
# ssh-add id_rsa
# ssh-add -L
