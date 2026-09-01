#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

componentTemplateFile=k8s/helm/component-patch-tpl.yaml
certManagerTempChart="/tmp/cert-manager"
certManagerTempValues="${certManagerTempChart}/values.yaml"
certManagerTempChartYaml="${certManagerTempChart}/Chart.yaml"

# this function will be sourced from release.sh and be called from release_functions.sh
update_versions_modify_files() {
  echo "Update helm dependencies"
  make helm-update-dependencies  > /dev/null

  # Extract cert-manager chart
  local certManagerVersion
  certManagerVersion=$(yq '.dependencies[] | select(.name=="cert-manager").version' < "k8s/helm/Chart.yaml")
  local certManagerPackage
  certManagerPackage="k8s/helm/charts/cert-manager-${certManagerVersion}.tgz"

  echo "Extract cert-manager helm chart"
  tar -zxvf "${certManagerPackage}" -C "/tmp" > /dev/null

  local certManagerAppVersion
  certManagerAppVersion=$(yq '.appVersion' < "${certManagerTempChartYaml}")

  echo "Set images in component patch template"

  local certManagerImageRegistry
  certManagerImageRegistry=$(yq '.imageRegistry' < "${certManagerTempValues}")
  local certManagerNamespace
  certManagerNamespace=$(yq '.imageNamespace' < "${certManagerTempValues}")

  setAttributeInComponentPatchTemplate ".values.images.certManagerController" "${certManagerImageRegistry}/${certManagerNamespace}/cert-manager-controller:${certManagerAppVersion}"
  setAttributeInComponentPatchTemplate ".values.images.certManagerWebhook" "${certManagerImageRegistry}/${certManagerNamespace}/cert-manager-webhook:${certManagerAppVersion}"
  setAttributeInComponentPatchTemplate ".values.images.certManagerCainjector" "${certManagerImageRegistry}/${certManagerNamespace}/cert-manager-cainjector:${certManagerAppVersion}"
  setAttributeInComponentPatchTemplate ".values.images.certManagerAcmesolver" "${certManagerImageRegistry}/${certManagerNamespace}/cert-manager-acmesolver:${certManagerAppVersion}"
  setAttributeInComponentPatchTemplate ".values.images.certManagerStartupapicheck" "${certManagerImageRegistry}/${certManagerNamespace}/cert-manager-startupapicheck:${certManagerAppVersion}"
  rm -rf ${certManagerTempChart}
}

setAttributeInComponentPatchTemplate() {
  local key="${1}"
  local value="${2}"

  yq -i "${key} = \"${value}\"" "${componentTemplateFile}"
}

update_versions_stage_modified_files() {
  git add "${componentTemplateFile}"
}
