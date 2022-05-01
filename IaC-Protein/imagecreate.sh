#!/bin/bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo yum install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
sudo yum install azure-cli -y

az vm deallocate --resource-group $1 --name $2
az vm generalize --resource-group $1 --name $2
az image create --resource-group $1 --name imgAlphaFold2cmd --source $2 --hyper-v-generation V2