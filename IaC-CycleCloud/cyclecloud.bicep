// CycleCloud environment buiding template
// Author: Xavier Cui (github.com/Iwillsky)
// License: MIT
// Date: 2022-04-18 (v1.0)

param spTenantId string = '72f988bf-86f1-41af-91ab-2d7cd011db47'
param spAppId string = '5514139f-04f0-45e4-9aff-ef48e12a7b18'
//@secure()
param spAppSecret string = 'JaIeO--hlAMv0Wy1J-5ox5fWi.MOY1s_Y6'
param keySSHpublic string = 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD37TYnbYRlY9rDqkxb8HmsBIrVw2B62aPZ0IExY4GnWyW8gJgfDGOSJPRG2iC6feD+xy4I0efFaKMxuS8+joBmBj86dj88xKfRD9gpsUKmhf92ybs0ZVlBsN3JYYBtxARPCRhjfTj9OZACTa4gWuJzAQPvWqGRE4j/MkRE+aCxuWj/unVKkJSHwii9yEjDRD8DhhDyceIz81X7AmxTBDr1ety8KZLcAZ8ZpVfjUqCJxICr4WenzYaq7zou6+RbohvQHANR9EMbLFSz/ISyf/VxmRb31Re19XyU5sSsKmXPq+xP5OMdiSMMnRmlyzDvawaF4Vstac5APm14afl06kMfDx4Ksy1MsN6JD23Ct/hDhgOB3xVHmDnmF6jAHfDFU2Mhbuqbt+PaS/VL7A9gI5dCVZGcfMMSSuv7acrZbem04dZGTzTsAyFihmb+unCICCQj074heOLAKjM02QZAA/jbJratO6JxvzKGG9sTsZwdg9hej+bfLKoANHdsY/j9Vjk= generated-by-azure'
param userName string = 'cycleadmin'
//@secure()
param userPass string = 'Passw0rd'
param nameStAcct string = 'asiahpcgbb'

//param urlScript string = 'https://raw.githubusercontent.com/CycleCloudCommunity/cyclecloud_arm/feature/update_cyclecloud_install/cyclecloud_install.py'
param prefixDeploy string = 'AF${uniqueString(resourceGroup().id)}'
param prefixIPaddr string = '10.18'
param curlocation string = resourceGroup().location

var skuCycleVM = 'Standard_D4s_v3'
var skuCycleDisk = 'Standard_LRS'
var nameVM = '${prefixDeploy}-cycleVM'
var nameNIC = '${prefixDeploy}-cycleNIC'
var nameNSG = '${prefixDeploy}-cycleNSG'
var nameIP = '${prefixDeploy}-cycleIP'
var nameRg = resourceGroup().name
//var nameANFvol = 'volAlpha'

resource cyclevnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name:'${prefixDeploy}-cyclevnet'
  location: curlocation
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${prefixIPaddr}.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'cycle'
        properties: {
          addressPrefix: '${prefixIPaddr}.1.0/24'
        }
      }
      {
        name: 'anf'
        properties: {
          addressPrefix: '${prefixIPaddr}.2.0/24'
          delegations: [
            { 
              name: 'Microsoft.NetApp.volumes'
              properties: {
                serviceName: 'Microsoft.NetApp/volumes'
              }                            
            }
          ]
        }
      }
      {
        name: 'compute'
        properties: {
          addressPrefix: '${prefixIPaddr}.4.0/22'
        }
      }
    ]
  }
}

resource cycleEIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: nameIP
  location: curlocation
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    dnsSettings: {
      domainNameLabel: toLower('${prefixDeploy}')
    }
  }
}
var cyclefqdn = cycleEIP.properties.dnsSettings.fqdn

resource cycleNSG 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nameNSG
  location: curlocation
  properties: {
    securityRules: [
      {
        name: 'AllowSecuredCyclePortalInBound'
        properties: {
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix:'Internet'
          destinationAddressPrefix: 'VirtualNetwork'
          priority: 1000
        } 
      }
      {
        name: 'AllowCyclePortalInBound'
        properties: {
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix:'Internet'
          destinationAddressPrefix: 'VirtualNetwork'
          priority: 1001
        }
      }
      {
        name: 'AllowSSHLink'
        properties: {
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix:'*'
          destinationAddressPrefix: '*'
          priority: 1002
        }
      }
    ]
  }
}

resource cycleNIC 'Microsoft.Network/networkInterfaces@2021-05-01' = {
  name: nameNIC
  location: curlocation
  properties: {    
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAddressVersion: 'IPv4'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: cycleEIP.id            
          }
          subnet: {
            id: cyclevnet.properties.subnets[0].id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: cycleNSG.id
    }       
  }
}

resource cycleVM 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: nameVM
  location: curlocation
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: skuCycleVM      
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: cycleNIC.id
        }
      ]
    }
    osProfile: {
      adminUsername: userName
      computerName: nameVM
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              keyData: keySSHpublic
              path: '/home/${userName}/.ssh/authorized_keys'
            }
          ]
        }
      }
    }
    storageProfile: {
      dataDisks: [
        {
          caching: 'ReadOnly'
          createOption: 'Empty'
          diskSizeGB: 128
          lun: 0
          managedDisk: {
            storageAccountType: skuCycleDisk
          }
        }
      ]
      imageReference: {
        offer: 'CentOS-HPC'
        publisher: 'OpenLogic'
        sku: '8_1'
        version: 'latest'        
      }
      osDisk: {
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: skuCycleDisk          
        }
        osType: 'Linux'
      } 
    }
  }  
}

//var cmd2run = 'echo "hello run command">>/tmp/hello.txt'
/*
resource cycleVMCmdRun 'Microsoft.Compute/virtualMachines/runCommands@2021-11-01' = {
  name: 'InstallCycle'
  location: curlocation
  parent: cycleVM
  properties: {
    parameters: [
      {
        name: 'p1'
        value: 'param1'
      }
      {
        name: 'p2'
        value: '1510'
      }
      {
        name: 'p3'
        value: 'backup'
      }
    ]    
    source: {
      //script: cmd2run
      scriptUri: 'https://asiahpcgbb.blob.core.windows.net/share/testsh.sh'      
    }
  }
}
*/

resource cycleVMExtension 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'CycleExtension'
  location: curlocation
  parent: cycleVM  
  properties: {
    autoUpgradeMinorVersion: true
    protectedSettings: {
      commandToExecute: 'python3 cyclecloud_install.py --acceptTerms --applicationSecret ${spAppSecret} --applicationId ${spAppId} --tenantId ${spTenantId} --azureSovereignCloud public --username ${userName} --password ${userPass} --publickey "${keySSHpublic}" --hostname ${cyclefqdn} --storageAccount ${nameStAcct} --resourceGroup ${nameRg} --useLetsEncrypt --webServerPort 80 --webServerSslPort 443 --webServerMaxHeapSize 4096M'
      //'python3 test.py --pval=1010'
    }
    publisher: 'Microsoft.Azure.Extensions'
    settings: {
      fileUris: [
        'https://raw.githubusercontent.com/CycleCloudCommunity/cyclecloud_arm/feature/update_cyclecloud_install/cyclecloud_install.py'
        //'https://asiahpcgbb.blob.core.windows.net/share/test.py'
      ]
    }
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
  }  
}
