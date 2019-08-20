#!/bin/bash

# this is a private script to be run by twistcli-scan.sh

# $1 should be the TL_VULN_THRESH of "", "low", "medium", "high", or "critical"
# $2 should be the TL_VULN_THRESH of "", "low", "medium", "high", or "critical"
# $3 should be the TL_ONLY_FIXED of "", true, false


args=();
[[ $1 != '' ]] && args+=( "--vulnerability-threshold $1" );
[[ $2 != '' ]] && args+=( "--compliance-threshold $2" );
[[ $3 == true ]] && args+=( '--only-fixed' );
echo ${args[@]}
