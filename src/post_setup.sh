#!/bin/bash

sed --in-place '/^users:/ {N; s/users:.*/users: []/g}' /etc/cloud/cloud.cfg
rm --force /etc/sudoers.d/90-cloud-init-users
rm --force /root/.ssh/authorized_keys
/usr/sbin/userdel --remove --force ubuntu
sudo snap switch --channel=candidate amazon-ssm-agent
sudo snap refresh amazon-ssm-agent
[[ -d /etc/amazon/ssm ]] || sudo mkdir --parents /etc/amazon/ssm
sudo cp --recursive --no-target-directory /snap/amazon-ssm-agent/current/ /etc/amazon/ssm/
sudo cp /snap/amazon-ssm-agent/current/seelog.xml.template /etc/amazon/ssm/seelog.xml
sudo snap restart amazon-ssm-agent
