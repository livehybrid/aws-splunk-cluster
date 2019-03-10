#!/usr/bin/env bash

until aws ssm get-parameter --name /ssh-keys/ops; do
    sleep 10
done

sudo mkdir -p /home/ubuntu/.ssh
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh


aws ssm get-parameter --name /ssh-keys/ops --with-decryption | jq -r '.Parameter.Value' > /home/ubuntu/.ssh/id_rsa
#aws ssm get-parameter --name /ssh-keys/management.pub | jq -r '.Parameter.Value' > /home/ubuntu/.ssh/id_rsa.pub

sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa
#sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa.pub

sudo chmod 600 /home/ubuntu/.ssh/id_rsa
#sudo chmod 600 /home/ubuntu/.ssh/id_rsa.pub