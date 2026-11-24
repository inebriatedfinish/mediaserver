#!/bin/bash

# Intended for a newly installed Docker instance on a linux machine.
# Will configure Docker to use log rotation.

# Add current user to the docker group.
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Configure Docker default log driver to limit size and use log rotation.
cat <<EOF | sudo tee /etc/docker/daemon.json > /dev/null
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3",
    "mode": "non-blocking",
    "max-buffer-size": "
  }
}
EOF

sudo systemctl restart docker