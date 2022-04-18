// Fast build template for AlphaFold2 on Azure HPC
// Author: Xavier Cui (github.com/Iwillsky)
// License: MIT
// Date: 2022-04-18 (v1.0)

// AF params
param AFsku_node string='Standard_T4'

// Call module building CycleCloud Env


// Create VM for Custom Image preparation
resource VM_imgAF 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: 'vmAFImgPrepare'
  location: 'useast-2'
}

