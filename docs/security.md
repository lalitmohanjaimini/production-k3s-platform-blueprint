# Security Model

## Trust boundaries

The platform separates five concerns:

- Edge and ingress
- Application workloads
- Data services
- Messaging services
- Administrative and observability access

Cross-namespace access should be allowed explicitly and reviewed as part of application delivery.

## Secrets

Do not commit Kubernetes Secret manifests containing real values.

Preferred approaches include:

- External Secrets Operator with a managed secret store
- SOPS-encrypted manifests with controlled key access
- Sealed Secrets with a protected recovery key

Secret rotation and recovery must be documented before production use.

## Workload controls

- Run containers as non-root when the image supports it.
- Drop Linux capabilities unless they are required.
- Use read-only root filesystems where practical.
- Set CPU and memory requests and limits.
- Pin images by immutable digest for controlled releases.
- Verify image provenance and scan for known vulnerabilities.
- Disable privilege escalation by default.

## Network controls

Start with default deny for ingress and egress. Add scoped policies for:

- DNS access
- Ingress-to-application traffic
- Application-to-database traffic
- Application-to-messaging traffic
- Monitoring scrapes
- Required external APIs

NetworkPolicy behavior depends on the installed CNI. Validate enforcement with positive and negative tests.

## Ingress and TLS

- Redirect HTTP to HTTPS.
- Use trusted certificates for public endpoints.
- Keep the Traefik dashboard disabled or administrator-only.
- Apply rate limiting and security headers at an appropriate layer.
- Do not expose database, cache or broker management ports publicly.

## Kubernetes access

- Use separate identities for people and automation.
- Grant namespace-scoped roles where possible.
- Avoid routine use of `cluster-admin`.
- Rotate kubeconfigs and remove unused credentials.
- Audit privileged workloads and broad RBAC grants.

## Supply chain

- Pin Helm chart versions.
- Review chart changes before upgrades.
- Use controlled container registries.
- Record image digests in release evidence.
- Run manifest and image scans in CI.

## Backup security

Backups must be encrypted in transit and at rest. Restore credentials should be separate from routine application credentials. Test that a backup can be restored without access to the original cluster.
