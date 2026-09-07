# Reference Architecture

## Design target

The reference platform uses three K3s nodes and assumes that workloads run on a private network behind an explicit edge or firewall boundary.

A three-node control-plane layout can tolerate one node failure when quorum and storage placement are healthy. It does not remove the need for tested backups or application-level resilience.

## Traffic flow

1. Public or internal clients resolve an application hostname.
2. The edge routes approved ports to a MetalLB-managed service address.
3. Traefik terminates TLS and selects a route.
4. Traffic reaches an application Service.
5. Applications access data and messaging systems through ClusterIP services.
6. Metrics and logs flow to the observability namespace.

Only Traefik should require an externally reachable LoadBalancer address in the default design.

## Namespace boundaries

| Namespace | Purpose | Default exposure |
|---|---|---|
| `platform-system` | Shared platform controllers and policies | Internal |
| `apps` | Application workloads | Through ingress only |
| `data` | PostgreSQL and document data | Cluster internal |
| `messaging` | RabbitMQ and asynchronous services | Cluster internal |
| `observability` | Metrics, dashboards, logs and alerts | Internal or administrator-only |

Controllers that require fixed namespaces—such as MetalLB or CloudNativePG—remain in their upstream-recommended namespaces.

## Networking decisions

- Use a non-overlapping MetalLB pool from the target LAN.
- Reserve addresses outside DHCP allocation.
- Start with Layer 2 advertisement unless the network requires BGP.
- Keep data services as `ClusterIP`.
- Apply default-deny NetworkPolicies, then add narrowly scoped allows.
- Confirm that the installed K3s CNI enforces NetworkPolicy before relying on policy objects.

The included `192.0.2.0/24` addresses are documentation-only.

## Stateful services

Stateful workloads require:

- A storage class with understood replication and failure behavior
- Pod anti-affinity or topology awareness
- Pod disruption budgets where supported
- Resource requests and limits based on measured workload
- Backups stored outside the cluster
- Periodic restore tests

High availability inside a cluster is not a backup strategy.

## Failure domains

Before production use, document:

- What happens when one worker disappears
- What happens when the control-plane leader disappears
- Whether persistent volumes survive node loss
- Which services can restart elsewhere
- How DNS and the load-balancer address recover
- How the platform is restored after total cluster loss

## Implementation order

1. Build and harden K3s nodes.
2. Install the CNI and confirm NetworkPolicy enforcement.
3. Install MetalLB and allocate a documentation-reviewed address pool.
4. Install Traefik and validate HTTP-to-HTTPS behavior.
5. Install storage and database operators.
6. Deploy data and messaging services without external exposure.
7. Install metrics, logs and alerting.
8. Apply security policies.
9. Run backup and restore exercises.
10. Promote application workloads only after acceptance checks.
