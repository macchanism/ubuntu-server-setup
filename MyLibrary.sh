#!/bin/bash

# Change SSH port num.
function changeSSHPort() {
    local ssh_port=${1}

    sudo sed -re "s/^(\#?)(Port)([[:space:]]+)(.*)/Port ${ssh_port}/" -i /etc/ssh/sshd_config
}

# Change UFW config
function changeUfw() {
    local ssh_port=${1}

    sudo ufw delete allow OpenSSH
    sudo ufw allow "${ssh_port}"/tcp
    sudo ufw reload
}
