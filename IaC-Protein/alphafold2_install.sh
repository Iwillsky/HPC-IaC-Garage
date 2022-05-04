#!/bin/bash
sudo yum install epel-release python3 -y
sudo yum install aria2 -y
sudo yum remove moby-cli.x86_64 moby-containerd.x86_64 moby-engine.x86_64 moby-runc.x86_64 -y
sudo yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.4.13-3.1.el7.x86_64.rpm
sudo yum install docker-ce -y
sudo systemctl --now enable docker
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.repo | sudo tee /etc/yum.repos.d/nvidia-container-toolkit.repo
sudo yum clean expire-cache
sudo yum install -y nvidia-docker2
sudo systemctl restart docker
sudo usermod -aGdocker $USER
newgrp docker
sudo su
cd /opt
git clone https://github.com/deepmind/alphafold.git
cd alphafold/
sed -i '/SHELL ["/bin/bash", "-c"]/a\RUN gpg --keyserver keyserver.ubuntu.com --recv A4B469963BF863CC && gpg --export --armor A4B469963BF863CC | apt-key add -' docker/Dockerfile
docker build -f docker/Dockerfile -t alphafold .
pip3 install -r docker/requirements.txt

sudo waagent -deprovision+user -force