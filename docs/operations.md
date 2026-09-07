# Operations Runbook

## Preflight

Confirm before installation:

- Three nodes have stable time synchronization and DNS.
- Required ports are open only between intended peers.
- The MetalLB range is reserved and does not overlap DHCP.
- Storage classes and failure behavior are documented.
- A DNS and certificate strategy exists.
- Backup storage is outside the cluster.
- Resource capacity includes failure headroom.

## Installation sequence

```text
K3s → CNI/policy validation → MetalLB → Traefik
     → data operators → databases and messaging
     → observability → security policies → applications
```

Pin every chart and image version in an environment-specific release record.

## Acceptance checks

- All nodes are `Ready`.
- CoreDNS answers cluster service queries.
- MetalLB assigns the expected test address.
- Traefik redirects HTTP and serves a trusted HTTPS route.
- Stateful pods survive a controlled restart.
- Applications can reach only their approved dependencies.
- Metrics targets are healthy and logs are searchable.
- Alerts reach the intended test destination.
- Backups complete and a restore test succeeds.

## Daily checks

- Node health and resource pressure
- Failed or pending pods
- Persistent-volume usage
- Database replication and backup status
- Queue depth and consumer health
- Ingress error rate and certificate expiry
- Alert delivery health

## Upgrade procedure

1. Read upstream release notes and breaking changes.
2. Confirm a recent restore test.
3. Upgrade a non-production environment.
4. Validate networking, storage and application smoke tests.
5. Upgrade one platform layer at a time.
6. Record versions, timestamps and rollback decisions.
7. Observe the platform before continuing.

## Backup and restore

Define service-specific RPO and RTO targets. Store backups outside the cluster and retain more than one recovery point.

A restore drill should prove:

- Credentials and encryption keys are available
- The target cluster can access backup storage
- Data consistency checks pass
- Applications can reconnect
- Recovery time meets the documented objective

## Incident sequence

1. Protect data and stop uncontrolled change.
2. Establish the blast radius.
3. Preserve relevant logs and events.
4. Restore the smallest safe service path.
5. Communicate known facts and next checkpoints.
6. Record the timeline and follow-up actions.
