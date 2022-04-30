#!/bin/bash
export myVM=af2ImgVM
export myImage=imgAlphaFold2cmd
export myResourceGroup=Rampup-study
az vm deallocate --resource-group $myResourceGroup --name $myVM
az vm generalize --resource-group $myResourceGroup --name $myVM
az image create --resource-group $myResourceGroup --name $myImage --source $myVM --hyper-v-generation V2