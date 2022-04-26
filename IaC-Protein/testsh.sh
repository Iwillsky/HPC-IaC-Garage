#!/bin/bash
wget https://raw.githubusercontent.com/CycleCloudCommunity/cyclecloud_arm/feature/update_cyclecloud_install/cyclecloud_install.py
wget https://asiahpcgbb.blob.core.windows.net/share/test.py
python3 test.py --pname $1 --pval $2 $3 $4
echo $1
echo $2
echo $3
echo $4