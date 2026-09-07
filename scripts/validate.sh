#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

echo "Checking for sensitive material..."
sensitive_pattern='BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|password:[[:space:]]+[^R]|token:[[:space:]]+[^R]|kubeconfig:'
if command -v rg >/dev/null 2>&1; then
  if rg -n --hidden -g '!.git/**' -g '!scripts/validate.sh' "$sensitive_pattern" .; then
    echo "Potential sensitive value found. Review before publishing." >&2
    exit 1
  fi
else
  if grep -RInE --exclude-dir=.git --exclude=validate.sh "$sensitive_pattern" .; then
    echo "Potential sensitive value found. Review before publishing." >&2
    exit 1
  fi
fi

echo "Checking YAML syntax and style when yamllint is available..."
if command -v yamllint >/dev/null 2>&1; then
  yamllint .yamllint.yml .github/workflows manifests
else
  echo "yamllint not installed; syntax lint skipped."
fi

echo "Checking Kubernetes schemas when kubeconform is available..."
if command -v kubeconform >/dev/null 2>&1; then
  find manifests -type f -name '*.yaml' ! -path '*/traefik/values.yaml' -print0 |
    xargs -0 kubeconform -strict -ignore-missing-schemas
else
  echo "kubeconform not installed; schema validation skipped."
fi

echo "Checking required documentation..."
for file in README.md SECURITY.md docs/architecture.md docs/disaster-recovery.md docs/service-recovery.md docs/security.md docs/operations.md; do
  test -s "$file" || { echo "Missing or empty: $file" >&2; exit 1; }
done

echo "Validation completed."
