#!/usr/bin/env bash
# Downloads latest official icon sets into icons/ directories.
# Run from repo root: bash scripts/download_icons.sh
# Requires: curl, unzip

set -euo pipefail

ICONS_DIR="$(cd "$(dirname "$0")/.." && pwd)/icons"

echo "==> Downloading AWS Architecture Icons..."
# Official quarterly release — update URL when AWS publishes new quarter
AWS_URL="https://d1.awsstatic.com/webteam/architecture-icons/Q32024/Asset-Package_Q32024.zip"
curl -fL "$AWS_URL" -o /tmp/aws-icons.zip
unzip -q -o /tmp/aws-icons.zip -d /tmp/aws-icons-extracted
# AWS ZIP contains nested folders — copy all SVGs into icons/aws/
find /tmp/aws-icons-extracted -name "*.svg" -exec cp {} "$ICONS_DIR/aws/" \;
echo "    AWS: $(ls "$ICONS_DIR/aws/" | wc -l | tr -d ' ') SVG files"

echo "==> Downloading GCP Icons..."
# Official GCP icon ZIP — check cloud.google.com/icons for latest URL
GCP_URL="https://storage.googleapis.com/cloud-devrel-public-assets/cloud-icons/Google_Cloud_Icons.zip"
curl -fL "$GCP_URL" -o /tmp/gcp-icons.zip
unzip -q -o /tmp/gcp-icons.zip -d /tmp/gcp-icons-extracted
find /tmp/gcp-icons-extracted -name "*.svg" -exec cp {} "$ICONS_DIR/gcp/" \;
echo "    GCP: $(ls "$ICONS_DIR/gcp/" | wc -l | tr -d ' ') SVG files"

echo "==> Downloading Kubernetes Icons..."
K8S_URL="https://github.com/kubernetes/community/archive/refs/heads/main.zip"
curl -fL "$K8S_URL" -o /tmp/k8s-community.zip
unzip -q -o /tmp/k8s-community.zip "community-main/icons/svg/*" -d /tmp/k8s-extracted
find /tmp/k8s-extracted -name "*.svg" -exec cp {} "$ICONS_DIR/k8s/" \;
echo "    K8s: $(ls "$ICONS_DIR/k8s/" | wc -l | tr -d ' ') SVG files"

echo "==> Downloading Azure Icons..."
AZURE_URL="https://arch-center.azureedge.net/icons/Azure_Public_Service_Icons_V23.zip"
curl -fL "$AZURE_URL" -o /tmp/azure-icons.zip
unzip -q -o /tmp/azure-icons.zip -d /tmp/azure-icons-extracted
find /tmp/azure-icons-extracted -name "*.svg" -exec cp {} "$ICONS_DIR/azure/" \;
echo "    Azure: $(ls "$ICONS_DIR/azure/" | wc -l | tr -d ' ') SVG files"

echo "==> Cloning CNCF Artwork (SVG logos for Argo, Istio, Prometheus, Cilium, etc.)..."
CNCF_TMP=/tmp/cncf-artwork
rm -rf "$CNCF_TMP"
git clone --depth=1 --quiet https://github.com/cncf/artwork.git "$CNCF_TMP"
# Copy icon-only (square, no text) SVGs for each project
find "$CNCF_TMP" -path "*/icon/*.svg" -exec cp {} "$ICONS_DIR/cncf/" \;
echo "    CNCF: $(ls "$ICONS_DIR/cncf/" | wc -l | tr -d ' ') SVG files"

echo "==> Downloading HashiCorp icons from diagrams library (fallback)..."
# HashiCorp brand ZIP requires agreeing to terms — use diagrams lib copies as fallback
pip show diagrams &>/dev/null || pip install diagrams -q
DIAG_PATH=$(python3 -c "import diagrams, os; print(os.path.dirname(diagrams.__file__))")
find "$DIAG_PATH/resources/onprem" -name "terraform*" -o -name "vault*" -o -name "consul*" -o -name "nomad*" | \
  while read f; do cp "$f" "$ICONS_DIR/hashicorp/"; done
echo "    HashiCorp: $(ls "$ICONS_DIR/hashicorp/" | wc -l | tr -d ' ') files (from diagrams lib)"

echo ""
echo "==> All icons downloaded."
echo "    Run 'python3 scripts/build_icon_index.py' to regenerate the lookup table."
