#!/bin/bash
set -e
apt-get update -y
apt-get install -y python3 python3-pip
pip3 install --upgrade pip
pip3 install polars
systemctl enable amazon-ssm-agent || true
systemctl start amazon-ssm-agent || true