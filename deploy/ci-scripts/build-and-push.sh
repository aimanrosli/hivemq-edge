#!/usr/bin/env bash
set -euo pipefail

# Configuration
LOCAL_REGISTRY="artifactory.local:8082/docker-local"
IMAGE_NAME="hivemq-edge"
TAG="${1:-latest}"

echo "=========================================================="
echo " HiveMQ Edge Local Air-Gapped CI Pipeline"
echo "=========================================================="

echo "[1/4] Building HiveMQ Edge OCI Image locally..."
./gradlew loadOciImage

echo "[2/4] Tagging image for JFrog Artifactory..."
docker tag "hivemq/${IMAGE_NAME}:latest" "${LOCAL_REGISTRY}/${IMAGE_NAME}:${TAG}"

echo "[3/4] Pushing image to offline JFrog registry..."
docker push "${LOCAL_REGISTRY}/${IMAGE_NAME}:${TAG}"

echo "[4/4] Updating GitOps Helm values image tag..."
sed -i.bak "s|tag:.*|tag: ${TAG}|g" deploy/helm/hivemq-edge/values.yaml
rm -f deploy/helm/hivemq-edge/values.yaml.bak

echo "=========================================================="
echo " CI Build & Push completed. Commit to Git to trigger ArgoCD."
echo "=========================================================="
