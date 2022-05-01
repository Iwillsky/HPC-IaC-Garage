#!/bin/bash

#commandToExecute: '/bin/bash multirun.sh ${spAppSecret} ${spAppId} ${spTenantId} ${typeSovereign} ${userName} ${userPass} "${keySSHpublic}" ${cyclefqdn} ${nameStAcct} ${nameRg}'      
python3 cyclecloud_install.py --acceptTerms --applicationSecret $1 --applicationId $2 --tenantId $3 --azureSovereignCloud $4 --username $5 --password $6 --publickey $7 --hostname $8 --storageAccount $9 --resourceGroup ${10} --useLetsEncrypt --webServerPort 80 --webServerSslPort 443 --webServerMaxHeapSize 4096M

#prepare custome image
/bin/bash imagecreate.sh