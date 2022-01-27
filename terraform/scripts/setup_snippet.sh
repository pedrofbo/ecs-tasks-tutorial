#!/bin/bash
curl https://raw.githubusercontent.com/pedrofbo/disk_monitor/main/setup.sh | bash \
    -s -- --sns-topic "${sns_topic}" --instance-name "${instance_name}"
