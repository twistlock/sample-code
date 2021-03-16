#!/bin/bash
# Documenting how the Splunk App is packaged

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b|--build)
      build_version=$2
      shift 2
      ;;
  esac
done

[[ -z $build_version ]] && echo "Please provide the build version with -b or --build." && exit 1

tar -czf pcc-splunk-app-${build_version}.tar.gz --exclude __pycache__ twistlock

# curl 'https://splunkbase.splunk.com/api/v1/app/4555/new_release/' \
#   -u wgill_panw \
#   -F "files[]=@pcc-splunk-app-${build_version}.tar.gz" \
#   -F "filename=pcc-splunk-app-${build_version}.tar.gz" \
#   -F "splunk_versions=8.1,8.0,7.3,7.2" \
#   -F "visibility=true"
