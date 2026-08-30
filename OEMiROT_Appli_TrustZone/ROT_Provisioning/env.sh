#!/bin/bash -
# Absolute path to this script  
if [ $# -ge 1 ] && [ -d $1 ]; then
    projectdir=$1
else
    projectdir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
fi
# ==============================================================================
#                               General
# ==============================================================================
#Configure tools installation path
VAR1=$OSTYPE
VAR2="Windows_NT"
user="" 
if [ "$VAR1" = "$VAR2" ]; then
    stm32programmercli="/home/rajas/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer_CLI"
    stm32tpccli="/home/rajas/STM32CubeMX/utilities/STM32TrustedPackageCreator/bin/STM32TrustedPackageCreator_CLI"
else	
    PATH="/home/rajas/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin":$PATH
    PATH="/home/rajas/STM32CubeMX/utilities/STM32TrustedPackageCreator/bin/STM32TrustedPackageCreator_CLI":$PATH
    stm32programmercli="/home/rajas/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer_CLI"
    stm32tpccli="/home/rajas/STM32CubeMX/utilities/STM32TrustedPackageCreator/bin/STM32TrustedPackageCreator_CLI"
fi
# ==============================================================================
#               !!!! DOT NOT EDIT --- UPDATED AUTOMATICALLY !!!!
# ==============================================================================
PROJECT_GENERATED_BY_CUBEMX=true
cube_fw_path="/home/rajas/STM32Cube/Repository/STM32Cube_FW_H5_V1.7.0"
oemirot_appli_path_project=OEMiROT_Appli_TrustZone

# ==============================================================================
#                            OEM_IROT bootpath
# ==============================================================================
oemirot_appli_secure=OEMiROT_Appli_TrustZone_Secure_enc_sign.hex
oemirot_appli_non_secure=OEMiROT_Appli_TrustZone_NonSecure_enc_sign.hex
oemirot_boot_path_project=/home/rajas/workspace/OEMiROT/OEMiROT_Boot
oemirot_boot=OEMiROT_Boot.bin
rot_provisioning_path=$projectdir

