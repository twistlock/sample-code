#!/bin/bash
# Documenting how the Splunk App is packaged

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--build)
      build_version=$2
      shift 2
      ;;
    -d|--directory)
      root_dir=$2
      shift 2
      ;;
  esac
done

# exit if either variable is missing
[[ -z $build_version ]] || [[ -z "$root_dir" ]] && exit 1

tar -czf pcc-splunk-app-${build_version}.tar.gz -C "$root_dir"/siem/splunk/ twistlock
