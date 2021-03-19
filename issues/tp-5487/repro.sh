#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

THIS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

pwd

key_types=(
    'rsa'
    #'dsa',
    #'ecdsa',
    #"ed25519"
)

test_timestamp=$(date +%s)

for key_type in "${key_types[@]}"; do
    test_working_dir_name="test_cert_support_${test_timestamp}_${key_type}"
    mkdir -p ${test_working_dir_name}
    pushd ${test_working_dir_name}

    echo $key_type
    echo generate CA key
    # ssh-keygen -t ${key_type} -C CA -f ca -b 2048 -q -N ""
    ssh-keygen -t ${key_type} -C CA -f ca -q -N ""

    echo generate client key
    # ssh-keygen -t ${key_type} -f id_${key_type} -b 2048 -q -N ""
    ssh-keygen -t ${key_type} -f id_${key_type} -q -N ""
    ssh-keygen -s ca -I user_key -n $(whoami) -V +52w id_${key_type}
    ssh-keygen -L -f id_${key_type}-cert.pub

    echo generate host key
    # ssh-keygen -t ${key_type} -f host_id_${key_type} -b 2048 -q -N ""
    ssh-keygen -t ${key_type} -f host_id_${key_type} -q -N ""
    ssh-keygen -s ca -I host_key -h host_id_${key_type}
    ssh-keygen -L -f host_id_${key_type}-cert.pub

    mkdir -p /run/sshd

    echo generate know_host_file
    $(which sshd) -d -f /dev/null -p 2345 \
        -o "HostKey $(pwd)/host_id_${key_type}" \
        -o "HostCertificate $(pwd)/host_id_${key_type}-cert.pub" \
        -o "TrustedUserCAKeys $(pwd)/ca.pub" &
    #get pid $! of the above
    #trap "kill $!" EXIT
    sleep 0.1
    ssh-keyscan -p 2345 localhost >known_host_file

    #eugene can find a flag to trust localhost sshd hosts
    echo add keys to ssh-agent
    eval "$(ssh-agent -s)"
    ssh-add -D
    ssh-add -L || true # if [-z  (command))
    ssh-add $(pwd)/id_${key_type}
    ssh-add -L

    echo test with ssh-agent
    $(which sshd) -d -f /dev/null -p 2345 \
        -o "HostKey $(pwd)/host_id_${key_type}" \
        -o "HostCertificate $(pwd)/host_id_${key_type}-cert.pub" \
        -o "TrustedUserCAKeys $(pwd)/ca.pub" &
    #trap "kill $!" EXIT
    sleep 0.1

    return_value_with_ssh_agent=$(ssh -o "UserKnownHostsFile $(pwd)/known_host_file" localhost -p 2345 echo hello)
    echo return_value_with_ssh_agent=${return_value_with_ssh_agent}
    eval "$(ssh-agent -k)"

    echo start gpg-agent
    eval $(${THIS_SCRIPT_DIR}/../../build-gnupg/agent/gpg-agent --verbose --verbose --homedir $(pwd) --enable-ssh-support --daemon --batch)
    ssh-add -D
    ssh-add -L || true
    ssh-add $(pwd)/id_${key_type}
    ssh-add -L

    $(which sshd) -d -f /dev/null -p 2345 \
        -o "HostKey $(pwd)/host_id_${key_type}" \
        -o "HostCertificate $(pwd)/host_id_${key_type}-cert.pub" \
        -o "TrustedUserCAKeys $(pwd)/ca.pub" &
    sleep 0.1

    return_value_with_gpg_agent=$(ssh -o "UserKnownHostsFile $(pwd)/known_host_file" localhost -p 2345 echo hello)
    echo return_value_with_gpg_agent=${return_value_with_gpg_agent}

    pkill gpg-agent

    if [ "$return_value_with_ssh_agent" = "$return_value_with_gpg_agent" ]; then
        echo "ssh agent and gpg agent returned same values."
        exit 0
    else
        echo "ssh agent and gpg agent returned DIFFERENT values."
        exit 1
    fi

    popd
done

# debugging commands
# systemctl --user stop gpg-agent gpg-agent-ssh.socket gpg-agent.socket gpg-agent-browser.socket gpg-agent-extra.socket
# ./gpg-agent --verbose --verbose   --enable-ssh-support  --daemon --no-detach
# export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
# ssh-add id_rsa
# ssh-add -L

# $(which sshd) -d  -p 2345 -o "HostKey $(pwd)/sshd_config.d/host_id_rsa" -o "HostCertificate $(pwd)/sshd_config.d/host_id_rsa-cert.pub)" &
# ssh -o "UserKnownHostsFile known_host_file" 0.0.0.0 -p 2345 exit 13
# echo $?

#make -f build-aux/speedo.mk  native SELFCHECK=0
#make -f build-aux/speedo.mk  native SELFCHECK=0 STATIC=1
#export LD_LIBRARY_PATH=/home/igor/git/gnupg-workspace/gnupg/PLAY/inst/bin/../lib
