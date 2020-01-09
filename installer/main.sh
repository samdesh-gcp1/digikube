#!/bin/bash
# Main installer script

local base_dir=~/
local digi_dir=${base_dir}digikube/
local kubectl_installer=${digi_dir}installer/kubectl.sh

${kubectl_installer}
