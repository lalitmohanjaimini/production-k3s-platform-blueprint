# Service Recovery Procedures

These procedures define recovery boundaries for MongoDB, Redis and RabbitMQ.
They complement PostgreSQL and Velero recovery in
[Backup and disaster recovery](disaster-recovery.md).

Every restore is performed into an isolated target first. Never point a restore
command at the active production service.

## MongoDB replica set

### Backup gate

Use a tested MongoDB Database Tools version compatible with the server. Run the
tool from an approved short-lived administrative workload whose connection URI
comes from the external secret system.

For a full logical replica-set dump:

```bash
mongodump \
  --uri="$MONGODB_URI" \
  --oplog \
  --archive=mongodb.archive \
  --gzip
```

Upload the archive to encrypted off-cluster storage and record its checksum.
Do not combine `--oplog` with namespace-limiting options.

### Restore gate

Provision a clean recovery replica set with no production ingress. Download and
verify the archive checksum, then restore:

```bash
mongorestore \
  --uri="$RECOVERY_MONGODB_URI" \
  --oplogReplay \
  --archive=mongodb.archive \
  --gzip
```

Validate replica health, document counts, indexes, critical queries and
application read/write smoke tests before considering traffic migration.

## Redis

First classify the workload:

- **Rebuildable cache:** document the source of truth, warm-up procedure and
  acceptable cold-cache impact. Do not claim an RPO based on Redis persistence.
- **Durable Redis data:** retain tested AOF or RDB copies outside the cluster,
  with encryption, checksum and a chart/version-compatible restore procedure.

The reference values enable AOF with `appendfsync everysec`. Confirm persistence
health using the `INFO persistence` output and test a backup copy before
maintenance. Restore into a new deployment from the selected AOF manifest or RDB
file using the Redis-version-supported preload/startup procedure.

Acceptance requires expected key counts, TTL behavior, Sentinel discovery and
application smoke tests.

## RabbitMQ

Export definitions from a running node to preserve virtual hosts, exchanges,
queues, bindings, policies and parameters:

```bash
rabbitmqctl export_definitions /tmp/definitions.json
```

Store the definitions file off-cluster with a checksum. Definition export does
not contain queued messages.

RabbitMQ message backup is a separate, workload-aware decision. A filesystem
copy of message data requires a coordinated cold-backup procedure with the
cluster stopped. For lower-downtime recovery, design a tested blue-green flow
with declarative topology, federation or shovel-based draining, publisher
confirms, consumer acknowledgements and idempotent processing.

Acceptance requires topology comparison plus publish, route, consume,
acknowledge and redelivery tests.

## Evidence checklist

For every service retain:

- Source version, operator/chart version and backup identifier
- Object checksum and storage retention result
- Recovery target and start/end timestamps
- Integrity and application smoke-test output
- Measured RPO and RTO
- Deviations, owners and remediation dates

Never save connection strings, credentials, internal hostnames or backup object
URLs in this public repository.
