#!/bin/bash -

# arg1 is the binary type (1 nonsecure, 2 secure)
signing=$1

# Getting the Trusted Package Creator and STM32CubeProgammer CLI path 
if [ $# -ge 1 ] && [ -d $1 ]; then
    projectdir=$1
else
    projectdir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
fi
provisioningdir="$(pwd)/../../ROT_Provisioning"
source "$provisioningdir/env.sh"
# Environement variable for log file
current_log_file="$projectdir/postbuild.log"
app_image_number=2
# ==============================================================================
#                            OEM_IROT bootpath
# ==============================================================================
s_code_xml="$provisioningdir/OEMiROT/Images/OEMiROT_S_Code_Image.xml"
ns_code_xml="$provisioningdir/OEMiROT/Images/OEMiROT_NS_Code_Image.xml"

applicfg="$cube_fw_path/Utilities/PC_Software/ROT_AppliConfig/dist/AppliCfg.exe"
uname | grep -i -e windows -e mingw
if [ $? == 0 ] && [ -e "$applicfg" ]; then
  #line for window executable
  echo AppliCfg with windows executable
  python=""
else
  #line for python
  echo AppliCfg with python script
  applicfg="$cube_fw_path/Utilities/PC_Software/ROT_AppliConfig/AppliCfg.py"
  #determine/check python version command
  python="python3 "
fi
# postbuild
echo "Postbuild $signing image" >> $current_log_file

if  [ $app_image_number -eq 1 ] && [ $signing == "nonsecure" ]; then
  echo "Creating only one image" >> $current_log_file
  $python$applicfg oneimage -fb "$appli_secure_path/$appli_secure" -sb "$appli_non_secure_path/$appli_non_secure" -o $secure_code_size -i 0x0 -ob "$appli_assembly_path/$appli_assembly" --vb >> $current_log_file
  if [ $? != 0 ]; then 
  	echo "Error with TPC see $current_log_file"
  fi
fi

if [ $signing == "secure" ]; then
  echo "Creating secure image"  >> $current_log_file
  "$stm32tpccli" -pb $s_code_xml >> $current_log_file
  if [ $? != 0 ]; then 
  	echo "Error with TPC see $current_log_file"
  fi
fi

if [ $signing == "nonsecure" ]; then
  echo "Creating nonsecure image"  >> $current_log_file
  "$stm32tpccli" -pb $ns_code_xml >> $current_log_file
  if [ $? != 0 ]; then 
  	echo "Error with TPC see $current_log_file"
  fi
fi

if [ $signing == "application" ]; then
  echo "Creating applcaition image"  >> $current_log_file
  "$stm32tpccli" -pb $code_xml >> $current_log_file
  if [ $? != 0 ]; then 
    echo "Error with TPC see $current_log_file"
  fi
fi

exit 0

