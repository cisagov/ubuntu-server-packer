#!/bin/bash

# Moved out of packer.pkr.hcl's inline provisioner shell to here.
# These commands come from here:
# https://github.com/cisagov/debian-packer/blob/e34570f730a04b680bcff5313384a1a13b4c935a/src/packer.pkr.hcl#L129
sed --in-place '/^users:/ {N; s/users:.*/users: []/g}' /etc/cloud/cloud.cfg
rm --force /etc/sudoers.d/90-cloud-init-users
rm --force /root/.ssh/authorized_keys
/usr/sbin/userdel --remove --force ubuntu

# The amazon-ssm-agent package in the stable channel is typically out-dated.
# In order to pull the latest stable version, Amazon recommends switching to the candidate channel.
# Also, the snap version of amazon-ssm-agent does not actually sync correctly with the service.
# Amazon recommends copying the data from the snap dir to one under /etc in order to collect logs correctly:
# https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-ubuntu-64-snap.html
sudo snap switch --channel=candidate amazon-ssm-agent
sudo snap refresh amazon-ssm-agent
[[ -d /etc/amazon/ssm ]] || sudo mkdir --parents /etc/amazon/ssm
sudo cp --recursive --no-target-directory /snap/amazon-ssm-agent/current/ /etc/amazon/ssm/
sudo cp /snap/amazon-ssm-agent/current/seelog.xml.template /etc/amazon/ssm/seelog.xml
sudo snap restart amazon-ssm-agent
