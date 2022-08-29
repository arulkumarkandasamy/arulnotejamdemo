#! /bin/bash
yum install -y epel-release
yum update -y
yum install -y tinyproxy
grep -qxF ‘Allow localhost’ /etc/tinyproxy/tinyproxy.conf || echo ‘Allow localhost’ >> /etc/tinyproxy/tinyproxy.conf
service tinyproxy restart
gcloud compute config-ssh