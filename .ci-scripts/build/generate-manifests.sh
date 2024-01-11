#!/bin/bash
#
# generate-manifests.sh
# Generates environment specific kubernetes manifests from 
# helm chart and specific values file.
#
# Requires:
#  - helm
#
# Assumed locations:
#  charts/<helm-chart>  - helm charts
#  deploy/<environment>/<chart-values.yaml  -values for enviroment in the format <chart>.yaml
set -e

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <chart> <environment | all>"
	exit 1
fi

CHART_DIR="charts"
DEPLOY_VALUES="deploy"
# DEPLOY_VALUES_PATH=${DEPLOY_VALUES}
MANIFESTS="kubernetes"
# MANIFESTS_PATH=${MANIFESTS}
# TEST_MANIFESTS="true"
CHART="$1"
ENVIRONMENT="$2"

# TODO: Test if environment exist function

# TODO:  After generation push-back manifests

function generate_manifests() {
    # Takes the target environment as argument
    local ENV="$1"
    echo "Generate ${CHART} kubernetes manifest for environment ${ENV}."
    mkdir -p "${MANIFESTS}/${ENV}"
    helm lint "${CHART_DIR}/${CHART}"
    helm template "${CHART_DIR}/${CHART}" \
        --namespace="${CHART}" \
        --values="${DEPLOY_VALUES}/${ENV}/${CHART}.yaml" \
        > "${MANIFESTS}/${ENV}/${CHART}.yaml"
    if [[ $? ]]; then
        echo "Manifests generated."
    fi
}

if [ 'all' != "${ENVIRONMENT}" ]; then
    # Create kubernetes manifests for single environment
    generate_manifests "${ENVIRONMENT}"
else
    #
    # Create kubernetes manifests per environment
    for ENV in "${DEPLOY_VALUES}"/*; do 
        if [ -f "${DEPLOY_VALUES}/${ENV##*/}/${CHART}".yaml ]; then
            # Strip leading path and trailing slashes
            generate_manifests "${ENV##*/}"
        fi
    done
fi