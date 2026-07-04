#!/usr/bin/env bash
# Downloads all auto-fetchable icon sets into icons/ directories.
# Run from repo root: bash scripts/download_icons.sh
#
# MANUAL DOWNLOADS REQUIRED (AWS/GCP/Azure require browser — no direct curl):
#   AWS:   https://aws.amazon.com/architecture/icons/  → download ZIP → unzip into icons/aws/
#   GCP:   https://cloud.google.com/icons              → download ZIP → unzip into icons/gcp/
#   Azure: https://learn.microsoft.com/en-us/azure/architecture/icons/ → download ZIP → unzip into icons/azure/

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ICONS_DIR="$REPO_ROOT/icons"

# ── Kubernetes (official, Apache-2.0 / CC-BY-4.0) ────────────────────────────
K8S_COUNT=$(ls "$ICONS_DIR/k8s/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$K8S_COUNT" -gt 10 ]; then
  echo "==> Kubernetes icons: already have $K8S_COUNT files — skipping download"
else
  echo "==> Kubernetes icons (github.com/kubernetes/community)..."
  K8S_TMP=$(mktemp -d)
  git clone --depth=1 --quiet https://github.com/kubernetes/community.git "$K8S_TMP"
  find "$K8S_TMP/icons/svg" -name "*.svg" -exec cp {} "$ICONS_DIR/k8s/" \;
  rm -rf "$K8S_TMP"
  echo "    k8s: $(ls "$ICONS_DIR/k8s/" | wc -l | tr -d ' ') SVG files"
fi

# ── CNCF Artwork (Argo, Istio, Prometheus, Cilium, Flux, Envoy, etc.) ────────
CNCF_COUNT=$(ls "$ICONS_DIR/cncf/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$CNCF_COUNT" -gt 100 ]; then
  echo "==> CNCF artwork: already have $CNCF_COUNT files — skipping download"
else
  echo "==> CNCF artwork (github.com/cncf/artwork)..."
  CNCF_TMP=$(mktemp -d)
  git clone --depth=1 --quiet https://github.com/cncf/artwork.git "$CNCF_TMP"
  find "$CNCF_TMP" -path "*/icon/*.svg" -exec cp {} "$ICONS_DIR/cncf/" \;
  # stacked fallbacks — avoid pipeline with set -e by using process substitution
  while IFS= read -r f; do
    base=$(basename "$f")
    [ ! -f "$ICONS_DIR/cncf/$base" ] && cp "$f" "$ICONS_DIR/cncf/"
  done < <(find "$CNCF_TMP" -path "*/stacked/color/*.svg")
  rm -rf "$CNCF_TMP"
  echo "    cncf: $(ls "$ICONS_DIR/cncf/" | wc -l | tr -d ' ') SVG files"
fi

# ── HashiCorp (raw SVG logos from each product's public GitHub repo) ──────────
echo "==> HashiCorp icons (raw logos from public GitHub repos)..."
while IFS='|' read -r project url; do
  outfile="$ICONS_DIR/hashicorp/${project}.svg"
  curl -fsSL "$url" -o "$outfile" 2>/dev/null \
    && echo "    + $project" \
    || rm -f "$outfile"
done <<'HCPLIST'
terraform|https://raw.githubusercontent.com/hashicorp/terraform/main/website/public/img/terraform-logo.svg
vault|https://raw.githubusercontent.com/hashicorp/vault/main/website/public/img/vault-logo.svg
consul|https://raw.githubusercontent.com/hashicorp/consul/main/website/public/img/consul-logo.svg
nomad|https://raw.githubusercontent.com/hashicorp/nomad/main/website/public/img/nomad-logo.svg
packer|https://raw.githubusercontent.com/hashicorp/packer/main/website/public/img/packer-logo.svg
HCPLIST
echo "    hashicorp: $(ls "$ICONS_DIR/hashicorp/" 2>/dev/null | wc -l | tr -d ' ') files (add more manually from hashicorp.com/brand)"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "==> Icon counts:"
for d in "$ICONS_DIR"/*/; do
  count=$(ls "$d" 2>/dev/null | wc -l | tr -d ' ')
  echo "    $(basename "$d"): $count files"
done

echo ""
echo "Manual steps for AWS / GCP / Azure:"
echo "  AWS:   https://aws.amazon.com/architecture/icons/"
echo "         → Download ZIP → unzip SVGs into icons/aws/"
echo "  GCP:   https://cloud.google.com/icons"
echo "         → Download ZIP → unzip SVGs into icons/gcp/"
echo "  Azure: https://learn.microsoft.com/en-us/azure/architecture/icons/"
echo "         → Download ZIP → unzip SVGs into icons/azure/"
echo ""
echo "Then run: python3 scripts/build_icon_index.py"
