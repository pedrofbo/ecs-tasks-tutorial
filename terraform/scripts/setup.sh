#!/bin/bash
set -e
mkdir -p /home/ubuntu/.disk_monitor/
git -C /home/ubuntu/.disk_monitor/ clone https://github.com/pedrofbo/disk_monitor.git
apt-get update
apt-get install -y python3-pip python3-virtualenv
virtualenv /home/ubuntu/.disk_monitor/.env
source /home/ubuntu/.disk_monitor/.env/bin/activate
pip3 install -r /home/ubuntu/.disk_monitor/disk_monitor/requirements.txt
mkdir -p /home/ubuntu/.aws
echo -e "[default]\nregion = us-east-1" >> /home/ubuntu/.aws/config
echo -e \
  '{\n\t"threshold": 0.2,\n\t"sns_topic": "${sns_topic}",\n\t"instance_name":"${project_name}"\n}' \
  >> /home/ubuntu/.disk_monitor/disk_monitor/config.json
echo "* * * * * cd /home/ubuntu/.disk_monitor/disk_monitor/; . ../.env/bin/activate; python monitor.py -c config.json" >> /tmp/disk_monitor
sudo -u ubuntu bash -c "crontab /tmp/disk_monitor"
