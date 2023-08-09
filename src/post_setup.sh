#!/bin/bash

sed -i '/^users:/ {N; s/users:.*/users: []/g}' /etc/cloud/cloud.cfg
rm --force /etc/sudoers.d/90-cloud-init-users
rm --force /root/.ssh/authorized_keys
/usr/sbin/userdel --remove --force ubuntu
sudo snap remove amazon-ssm-agent
sudo snap switch --channel=candidate amazon-ssm-agent
sudo snap install amazon-ssm-agent --classic
[[ -d /etc/amazon/ssm ]] || sudo mkdir -p /etc/amazon/ssm
sudo cp -R -p /snap/amazon-ssm-agent/current/ /etc/amazon/ssm/
sudo cp -p /snap/amazon-ssm-agent/current/seelog.xml.template /etc/amazon/ssm/seelog.xml
sudo sed 's/info/debug/' /etc/amazon/ssm/seelog.xml

echo "contents of /snap/amazon-ssm-agent/current/:"
sudo ls -l /snap/amazon-ssm-agent/current/
echo "
contents of /etc/amazon/ssm/:"
sudo ls -l /etc/amazon/ssm/
echo checking if ssm-user user exists:
grep "ssm-user" /etc/passwd
echo checking if ssm-user group exists:
grep "ssm-user" /etc/group
[[ $(getent group ssm-user) ]] || sudo useradd --user-group ssm-user
echo "ssm-user ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/ssm-user
[[ $(sudo snap list amazon-ssm-agent) ]] || sudo snap start amazon-ssm-agent
sudo snap services amazon-ssm-agent
sudo snap restart amazon-ssm-agent
sudo systemctl status snap.amazon-ssm-agent.amazon-ssm-agent.service
echo "amazon-ssm-agent debug log:"
sudo cat /etc/amazon/ssm/seelog.xml
sudo systemctl is-active ssh.service
sudo ufw disable
