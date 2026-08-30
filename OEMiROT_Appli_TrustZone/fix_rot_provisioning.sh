#!/bin/bash -
# Re-applies fixes that STM32CubeMX's "Generate Code" wipes out of
# ROT_Provisioning/ on every regeneration (OEM_IROT BootPath template bugs):
#   1. env.sh: oemirot_appli_path_project is never emitted by the generator,
#      but ob_flash_programming.sh requires it to locate this project's own
#      signed Binary/ output.
#   2. env.sh: oemirot_boot_path_project / oemirot_boot are declared with the
#      bash builtin `set VAR=value` instead of a plain assignment, so `set`
#      just reassigns positional parameters and the variables are never
#      actually defined (this also corrupts $1/AUTO-mode detection in any
#      script that sources env.sh). The value itself is re-derived from the
#      .ioc's BootPath settings each run, so this tracks wherever CubeMX's
#      BootPath is currently pointed (vendor package vs. local OEMiROT_Boot)
#      instead of a stale hardcoded guess.
#   3. ob_flash_programming.sh: both branches of the isGeneratedByCubeMX
#      check build appli_dir one directory level too shallow.
#   4. ob_flash_programming.sh: the "Write OEMiROT_Boot" step prefixes
#      oemirot_boot_path_project with $cube_fw_path/Projects/NUCLEO-H563ZI/,
#      which only makes sense when BootPath.OEMiRoTRelativeLocation=true in
#      the .ioc. When it's false (pointing at a local, absolute project path
#      -- the current setup, since OEMiROT_Boot now lives in this workspace
#      instead of the vendor package), that prefix breaks the path. This
#      strips the prefix so oemirot_boot_path_project is used as-is.
#   5. env.sh: rot_provisioning_path is emitted as $projectdir"/../", which
#      resolves one directory level above ROT_Provisioning/ -- the data-image
#      lookups in ob_flash_programming.sh (s_data_init_sign.hex etc.) then
#      miss even when the files exist. Fixed to plain $projectdir.
#
# Safe to re-run any number of times (idempotent). Run this after every
# STM32CubeMX code regeneration, before flashing.

set -e
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

env_sh="ROT_Provisioning/env.sh"
flash_sh="ROT_Provisioning/OEMiROT/ob_flash_programming.sh"
ioc=$(ls -- *.ioc 2>/dev/null | head -1)

# --- env.sh: fix 1 - add oemirot_appli_path_project if missing ---
if ! grep -q '^oemirot_appli_path_project=' "$env_sh"; then
    sed -i '/^cube_fw_path=/a oemirot_appli_path_project=OEMiROT_Appli_TrustZone' "$env_sh"
    echo "env.sh: added oemirot_appli_path_project"
fi

# --- env.sh: fix 2 - replace broken `set VAR=...` lines with plain assignments,
#     deriving the boot path value from the .ioc's BootPath settings ---
if grep -q '^set oemirot_boot_path_project=' "$env_sh" || grep -q '^oemirot_boot_path_project=Projects/' "$env_sh"; then
    boot_value="Applications/ROT/OEMiROT_Boot"   # fallback: vendor-relative default
    if [ -n "$ioc" ]; then
        # OEMiRoTCurrentLocation is the resolved path to the actual Boot project
        # CubeMX is pointed at (local, absolute here); OEMiRoTLocation is just the
        # vendor-relative template string and must NOT be used to locate the binary.
        loc=$(grep -m1 '^ProjectManager.BootPath.OEMiRoTCurrentLocation=' "$ioc" | cut -d= -f2-)
        [ -n "$loc" ] && boot_value="$loc"
    fi
    sed -i \
        -e "s#^set oemirot_boot_path_project=.*#oemirot_boot_path_project=$boot_value#" \
        -e "s#^oemirot_boot_path_project=Projects/.*#oemirot_boot_path_project=$boot_value#" \
        -e 's#^set oemirot_boot=\(.*\)#oemirot_boot=\1#' \
        "$env_sh"
    echo "env.sh: fixed oemirot_boot_path_project (= $boot_value) / oemirot_boot assignments"
fi

# --- ob_flash_programming.sh: fix 3 - correct appli_dir depth in both branches ---
if grep -q 'appli_dir=\$oemirot_appli_path_project$' "$flash_sh"; then
    sed -i 's#appli_dir=\$oemirot_appli_path_project$#appli_dir="../../../$oemirot_appli_path_project"#' "$flash_sh"
    echo "ob_flash_programming.sh: fixed true-branch appli_dir"
fi
if grep -q 'appli_dir="\.\./\.\./\$oemirot_appli_path_project"' "$flash_sh"; then
    sed -i 's#appli_dir="\.\./\.\./\$oemirot_appli_path_project"#appli_dir="../../../$oemirot_appli_path_project"#' "$flash_sh"
    echo "ob_flash_programming.sh: fixed else-branch appli_dir"
fi

# --- ob_flash_programming.sh: fix 4 - drop the vendor-package prefix on the
#     OEMiROT_Boot.bin path so an absolute oemirot_boot_path_project works ---
if grep -q '\$cube_fw_path/Projects/NUCLEO-H563ZI/\${oemirot_boot_path_project}/Binary/OEMiROT_Boot.bin' "$flash_sh"; then
    sed -i 's#\$cube_fw_path/Projects/NUCLEO-H563ZI/\${oemirot_boot_path_project}/Binary/OEMiROT_Boot.bin#${oemirot_boot_path_project}/Binary/OEMiROT_Boot.bin#' "$flash_sh"
    echo "ob_flash_programming.sh: dropped vendor-package prefix from OEMiROT_Boot.bin path"
fi

# --- env.sh: fix 5 - rot_provisioning_path must resolve to $projectdir itself ---
if grep -q '^rot_provisioning_path=\$projectdir"/\.\./"' "$env_sh"; then
    sed -i 's#^rot_provisioning_path=\$projectdir"/\.\./"#rot_provisioning_path=$projectdir#' "$env_sh"
    echo "env.sh: fixed rot_provisioning_path"
fi

echo "fix_rot_provisioning.sh: done"
