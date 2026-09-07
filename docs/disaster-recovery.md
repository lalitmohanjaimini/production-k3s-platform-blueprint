# Backup and Disaster Recovery

## Recovery objectives

Define business-approved recovery point and recovery time objectives before deployment.
The sample schedules in this repository are implementation examples, not an SLA.

| Scope | Reference mechanism | Example cadence | Recovery proof |
|---|---|---:|---|
| PostgreSQL data | Barman Cloud Plugin, WAL archive and base backup | Daily base backup plus continuous WAL | Restore into a new cluster and run consistency checks |
| Kubernetes configuration | Velero Schedule | Daily | Restore into an isolated namespace or replacement cluster |
| MongoDB data | Operator-supported logical or snapshot workflow | Environment-specific | Restore a replica set and validate application reads |
| Redis | Rebuild cache where possible; otherwise service-specific persistence | Environment-specific | Rehydrate or restore and verify application behavior |
| RabbitMQ | Declarative definitions plus workload-aware recovery plan | On topology change | Recreate definitions and validate publish/consume flow |

## Storage boundaries

- Keep backup storage outside the K3s cluster and outside its failure domain.
- Use a dedicated bucket or prefix per environment.
- Encrypt backups in transit and at rest.
- Manage credentials outside Git; grant write access only to backup components.
- Give recovery identities read-only access where the provider supports it.
- Enable object locking or immutable retention where business requirements demand it.
- Monitor backup age, failures, capacity and retention cleanup.

## PostgreSQL

The reference Cluster delegates WAL archiving to the Barman Cloud Plugin. The
`ObjectStore` resource defines the sanitized S3-compatible destination and retention,
while `ScheduledBackup` creates a daily base backup.

A PostgreSQL recovery is intentionally non-destructive: bootstrap a new Cluster from
the backup source, validate it, and move application traffic only after approval.
Do not overwrite the active cluster during a drill.

## Kubernetes configuration

The Velero schedule backs up selected platform namespaces without volume snapshots
or Secrets. Stateful data stays under each service's native recovery mechanism, and
credentials must be recreated from the external secret system.

Before relying on this schedule, verify that every required custom resource definition,
cluster-scoped dependency and externally managed Secret can be recreated.

For MongoDB, Redis and RabbitMQ procedures, see [Service recovery](service-recovery.md).

## Restore drill

Run at least quarterly and after material storage, operator or schema changes.

1. Record the backup identifier, source commit, expected RPO and start time.
2. Provision an isolated recovery target with no production ingress.
3. Recreate operators, CRDs and externally managed credentials.
4. Restore Kubernetes configuration.
5. Restore PostgreSQL into a new Cluster and replay WAL to the selected target.
6. Rebuild or restore MongoDB, Redis and RabbitMQ using their approved procedures.
7. Run integrity queries and application smoke tests.
8. Compare actual RPO and RTO with approved objectives.
9. Retain evidence before deleting the isolated recovery environment.
10. Record findings, owners and remediation deadlines.

## Acceptance evidence

A recovery milestone is complete only when the team retains:

- Successful backup and restore identifiers
- Start, checkpoint and completion timestamps
- Data consistency and application smoke-test results
- Evidence that production credentials were not exposed
- Actual RPO and RTO measurements
- Exceptions, owners and follow-up dates

## Safety

Never place real endpoints, bucket names or credentials in this public repository.
Pin tested operator, plugin and chart versions in the environment repository. Validate
all manifests and rehearse the full procedure in non-production before use.
