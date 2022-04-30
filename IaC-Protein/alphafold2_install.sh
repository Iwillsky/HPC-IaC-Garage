#!/bin/bash
sudo yum install epel-release python3 -y
sudo yum install aria2 -y
sudo yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo yum repolist -v
sudo yum install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.4.3-3.1.el7.x86_64.rpm
sudo yum install docker-ce -y
sudo systemctl --now enable docker
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
sudo yum clean expire-cache
sudo yum install -y nvidia-docker2
sudo systemctl restart docker
sudo usermod -aGdocker $USER
newgrp docker
docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
sudo su
cd /opt
git clone https://github.com/deepmind/alphafold.git
cd alphafold/
sudo docker build -f docker/Dockerfile -t alphafold .
sudo pip3 install -r docker/requirements.txt

sudo waagent -deprovision+user -force