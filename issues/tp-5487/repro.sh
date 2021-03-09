#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

pwd

key_types=( 
    'rsa'
    #'dsa',
    #'ecdsa',
    #"ed25519"
    )

mkdir -p tmp
cd tmp

for key_type in "${key_types[@]}"
do
    echo $key_type
    echo generate CA key
    # ssh-keygen -t ${key_type} -C CA -f ca -b 2048 -q -N ""
    ssh-keygen -t ${key_type} -C CA -f ca -q -N ""

    echo generate client key
    # ssh-keygen -t ${key_type} -f id_${key_type} -b 2048 -q -N ""
    ssh-keygen -t ${key_type} -f id_${key_type} -q -N ""
    ssh-keygen -s ca -I user_key -n $USERNAME -V +52w id_${key_type} 
    ssh-keygen -L -f id_${key_type}-cert.pub

    echo generate host key
    # ssh-keygen -t ${key_type} -f host_id_${key_type} -b 2048 -q -N ""
    ssh-keygen -t ${key_type} -f host_id_${key_type}  -q -N ""
    ssh-keygen -s ca -I host_key -h host_id_${key_type}
    ssh-keygen -L -f host_id_${key_type}-cert.pub 

    echo generate know_host_file
    $(which sshd) -d -f /dev/null -p 2345 \
        -o "HostKey $(pwd)/host_id_${key_type}" \
        -o "HostCertificate $(pwd)/host_id_${key_type}-cert.pub" \
        -o "TrustedUserCAKeys $(pwd)/ca.pub" & 

    sleep 0.1
    ssh-keyscan -p 2345 localhost > known_host_file

    echo add keys to ssh-agent
    eval "$(ssh-agent -s)"
    ssh-add -D
    ssh-add -L || true
    ssh-add $(pwd)/id_${key_type}
    ssh-add -L

    echo test with ssh-agent
    $(which sshd) -d -f /dev/null -p 2345 \
        -o "HostKey $(pwd)/host_id_${key_type}" \
        -o "HostCertificate $(pwd)/host_id_${key_type}-cert.pub" \
        -o "TrustedUserCAKeys $(pwd)/ca.pub" & 
    sleep 0.1

    return_code_from_ssh=$(ssh -o "UserKnownHostsFile $(pwd)/known_host_file" localhost -p 2345 echo hello)
    echo return_code_from_ssh=${return_code_from_ssh}
    eval "$(ssh-agent -k)"

    echo start gpg-agent
    eval $(../../../build-gnupg/agent/gpg-agent --verbose --verbose --homedir $(pwd) --enable-ssh-support  --daemon )
    ssh-add -D
    ssh-add -L || true
    ssh-add id_${key_type}
    ssh-add -L

    $(which sshd) -d -f /dev/null -p 2345 \
        -o "HostKey $(pwd)/host_id_${key_type}" \
        -o "HostCertificate $(pwd)/host_id_${key_type}-cert.pub" \
        -o "TrustedUserCAKeys $(pwd)/ca.pub" & 
    sleep 0.1

    return_code_from_ssh=$(ssh -o "UserKnownHostsFile $(pwd)/known_host_file" localhost -p 2345 echo hello)
    echo return_code_from_ssh=${return_code_from_ssh}

    killall gpg-agent
done

# gpg-connect-agent 'getinfo version' /bye
# # ouch gpg stores key in cache that persists across reboots
# # needs to be clean out manually with:
# # gpg-connect-agent 'keyinfo --list' /bye
# # gpg-connect-agent 'delete_key ...;
# # possibly (arg!) gpg --delete-secret-keys  FB5638933DF2C76365DD3DEBF300F05914337732
# # possibly (arg!) gpg --delete-keys  FB5638933DF2C76365DD3DEBF300F05914337732
# export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
# ssh-add -D
# ssh-add -L || true
# ssh-add id_{key_type}
# ssh-add -L

# ssh -o "UserKnownHostsFile known_host_file" 0.0.0.0 -p 2345 exit 13
# echo $?

# debugging commands
# systemctl --user stop gpg-agent gpg-agent-ssh.socket gpg-agent.socket gpg-agent-browser.socket gpg-agent-extra.socket
# ./gpg-agent --verbose --verbose   --enable-ssh-support  --daemon --no-detach 
# export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
# ssh-add id_rsa
# ssh-add -L

# $(which sshd) -d  -p 2345 -o "HostKey $(pwd)/sshd_config.d/host_id_rsa" -o "HostCertificate $(pwd)/sshd_config.d/host_id_rsa-cert.pub)" & 
# ssh -o "UserKnownHostsFile known_host_file" 0.0.0.0 -p 2345 exit 13
# echo $?

