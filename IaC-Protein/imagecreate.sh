#!/bin/bash
export myVM=af2ImgVM
export myImage=imgAlphaFold2
export myResourceGroup=Rampup-study
az vm deallocate --resource-group $myResourceGroup --name $myVM
az vm generalize --resource-group $myResourceGroup --name $myVM
az image create --resource-group $myResourceGroup --name $myImage --source $myVM --hyper-v-generation V2

wget https://raw.githubusercontent.com/CycleCloudCommunity/cyclecloud_arm/feature/update_cyclecloud_install/cyclecloud_install.py
wget https://asiahpcgbb.blob.core.windows.net/share/test.py
python3 test.py --pname $1 --pval $2 $3 $4
echo $1
echo $2
echo $3
echo $4