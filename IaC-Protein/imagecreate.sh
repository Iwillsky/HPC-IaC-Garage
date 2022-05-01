#!/bin/bash
az vm deallocate --resource-group $1 --name $2
az vm generalize --resource-group $1 --name $2
az image create --resource-group $1 --name imgAlphaFold2cmd --source $2 --hyper-v-generation V2