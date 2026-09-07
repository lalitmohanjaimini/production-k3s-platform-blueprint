# Data and messaging layer

This phase adds operator-oriented MongoDB and RabbitMQ examples plus authenticated Redis replication with Sentinel.

## Design intent

- Keep every datastore and broker on `ClusterIP`; external load balancers are not the default.
- Use three members where quorum or automatic failover depends on an odd replica count.
- Spread stateful replicas across Kubernetes nodes.
- Reference externally managed Secrets instead of committing credentials.
- Treat storage class, capacity, chart version and image digest as environment decisions.
- Enable metrics endpoints, but expose them only to the observability namespace.
- Test recovery procedures before accepting a configuration for production.

## MongoDB

`manifests/mongodb/community-replica-set.yaml` uses the MongoDB Community Kubernetes Operator to manage a
three-member replica set. Replace the version placeholder with a tested MongoDB 8.0 patch release.

The external secret workflow must create `mongodb-app-user-password` in the `data` namespace. The operator
creates the SCRAM credential Secret referenced by the resource.

Before rollout, validate node capacity, persistent volume behavior, topology spread and replica-set recovery.

## Redis

`manifests/redis/values.yaml` is a focused values overlay for an authenticated replication deployment with
three replicas and Sentinel quorum. Install it with a pinned, tested chart version:

```bash
helm upgrade --install redis oci://registry-1.docker.io/bitnamicharts/redis \
  --namespace data \
  --version REPLACE_ME \
  --values manifests/redis/values.yaml
```

Create the `redis-auth` Secret through the external secret workflow. Do not place credentials in values files.

Redis persistence does not replace backups. Confirm whether the workload needs cache-only behavior or durable
recovery guarantees, then test accordingly.

## RabbitMQ

`manifests/rabbitmq/cluster.yaml` uses the RabbitMQ Cluster Kubernetes Operator with three members, persistent
volumes, resource boundaries and required pod anti-affinity.

Keep AMQP internal. Expose the management interface only through an authenticated administrative path. Prefer
quorum queues for replicated durable workloads and verify quorum health before maintenance.

## Network policy

`manifests/network-policies/data-and-messaging.yaml` establishes default-deny boundaries, permits intra-namespace
cluster traffic, allows application access only to MongoDB, Redis and AMQP client ports, and retains DNS egress.

These policies require a network-policy-capable CNI. Validate selectors and operator-created pod traffic in a
non-production cluster before enforcement.

## Recovery boundaries

The three services do not share one safe backup mechanism:

- MongoDB replica-set dumps use `mongodump --oplog` when logical backup is
  appropriate; restore validation uses `mongorestore --oplogReplay` in a
  separate recovery deployment.
- Redis persistence protects restartability, not off-cluster recovery. Decide
  explicitly whether the workload is a rebuildable cache or durable data.
- RabbitMQ definition exports preserve topology but not queued messages. Message
  recovery requires a documented cold-backup or blue-green strategy.

See [Service recovery procedures](service-recovery.md) for detailed gates,
commands and acceptance evidence.
