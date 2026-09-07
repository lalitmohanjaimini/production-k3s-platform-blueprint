# Production K3s Platform Blueprint

A production-minded reference architecture for running application workloads on a compact K3s cluster with clear networking, data, messaging, observability and security boundaries.

> Public and vendor-neutral by design. Every address, domain, secret name and environment value is an example.

## Why this repository exists

Small Kubernetes platforms still need disciplined architecture. This blueprint demonstrates how a lightweight K3s foundation can support stateful services and application delivery without losing operational clarity.

The repository documents decisions and validation steps—not a universal copy-paste production environment.

## Architecture principles

- **Explicit traffic flow** — ingress, load-balancer addresses and service exposure are intentional
- **Stateful systems deserve lifecycle-aware tooling** — use operators where they reduce operational risk
- **Internal by default** — data and messaging services stay private unless exposure is justified
- **Observable operations** — metrics, logs and alerts are part of the platform
- **Recoverability over assumptions** — backup and restore procedures must be tested
- **No secrets in Git** — credentials come from an external secret workflow

## Reference topology

```mermaid
flowchart TB
    U[Users and clients] --> E[Edge or firewall]
    E --> M[MetalLB service address]
    M --> T[Traefik ingress]
    T --> A[Application workloads]
    A --> P[(PostgreSQL)]
    A --> G[(MongoDB)]
    A --> R[(Redis)]
    A --> Q[RabbitMQ]
    A --> O[Metrics and logs]
    P --> O
    G --> O
    R --> O
    Q --> O
```

## Platform layers

| Layer | Reference choice | Responsibility |
|---|---|---|
| Kubernetes | K3s, three nodes | Scheduling, service discovery and workload lifecycle |
| Load balancing | MetalLB | Stable service addresses on bare-metal or private networks |
| Ingress | Traefik | HTTP/S routing, TLS termination and middleware |
| Relational data | CloudNativePG | PostgreSQL high availability and recovery lifecycle |
| Document data | MongoDB | Document workloads with persistent storage |
| Cache | Redis | Caching, coordination and ephemeral state |
| Messaging | RabbitMQ | Durable asynchronous communication |
| Observability | Prometheus, Grafana, Loki | Metrics, dashboards, logs and alerts |
| Runtime security | Falco and Kubernetes policies | Workload visibility and guardrails |

## Repository contents

```text
.
├── docs/
│   ├── architecture.md
│   ├── operations.md
│   └── security.md
├── manifests/
│   ├── metallb/
│   ├── network-policies/
│   ├── postgresql/
│   └── traefik/
├── scripts/
│   └── validate.sh
├── SECURITY.md
└── README.md
```

## Quick start

1. Read [Architecture](docs/architecture.md), [Security](docs/security.md) and [Operations](docs/operations.md).
2. Replace every `REPLACE_ME` value and documentation-only address.
3. Confirm storage classes, failure domains, DNS, TLS and backup destinations.
4. Validate locally:

```bash
./scripts/validate.sh
```

5. Apply examples deliberately—never blindly—to a non-production cluster first.

## Safety boundaries

Never commit real IP addresses, internal DNS names, credentials, kubeconfigs, certificates, cloud identifiers, customer configuration or encryption keys.

The address range `192.0.2.0/24` used here is reserved for documentation and must be replaced.

## Status

**v0.1 foundation:** architecture, networking, ingress, PostgreSQL, security policies, operational guidance and validation.

## Author

**Lalit Mohan Jaimini**  
Technology Leader & Systems Architect

[Portfolio](https://lalitjaimini.com/) · [LinkedIn](https://www.linkedin.com/in/lalitmohanjaimini/) · [GitHub](https://github.com/lalitmohanjaimini)
