# Observability

This phase adds a metrics, alerting and logging reference for the three-node K3s platform.

## Stack

- Prometheus Operator and Prometheus for cluster and workload metrics
- Alertmanager with externally managed routing configuration
- Grafana with persistent storage and externally managed administrator credentials
- Loki in three-replica HA monolithic mode backed by external object storage
- Grafana Alloy as a DaemonSet for Kubernetes pod log collection
- PrometheusRule and ServiceMonitor resources for platform-specific visibility

## Why HA monolithic Loki

A compact three-node platform does not need the operational weight of full Loki microservices. Three monolithic
replicas provide high availability while external object storage separates durable log data from pod lifecycle.

Simple Scalable Deployment is intentionally not used because it is being deprecated before Loki 4.0.

## Why Grafana Alloy

Promtail reached end of life on 2 March 2026. Alloy is the supported Grafana collector and can forward pod logs
to the internal Loki gateway without requiring Loki to be exposed publicly.

## Security boundaries

- Prometheus, Grafana, Loki and Alertmanager remain `ClusterIP` services.
- Grafana credentials come from the `grafana-admin` Secret.
- Alert routing configuration comes from the `alertmanager-config` Secret.
- Loki object-store access must use workload identity or an external secret injection mechanism.
- No cloud access keys, notification tokens or internal hostnames belong in this repository.
- Administrative access should pass through authenticated ingress, VPN or a controlled port-forward.

## Capacity and retention

The supplied values are starting points, not sizing guarantees:

- Prometheus retains 15 days with a 40 GiB size ceiling.
- Loki retains logs for 28 days in external object storage.
- Alertmanager retains local state for five days.
- Persistent volume sizes and resource limits must be load-tested.

Track ingestion rate, active series, query latency, WAL growth, object-store request cost and disk pressure before
adjusting retention.

## Install order

1. Create externally managed Grafana and Alertmanager Secrets.
2. Install `kube-prometheus-stack` with a pinned chart version.
3. Apply the custom PrometheusRule and ServiceMonitor resources.
4. Provision unique Loki object-store buckets and workload identity.
5. Install the Grafana Community Loki chart with a pinned version.
6. Install Grafana Alloy and confirm each node is represented.
7. Verify metrics targets, alert delivery, log ingestion and log queries.

## Validation gates

Before production approval, prove:

- A node loss does not stop metrics ingestion or log writes.
- Alertmanager routes a synthetic warning and critical alert.
- Grafana restarts without losing its configuration database.
- Loki rejects unavailable or invalid storage credentials without silently dropping logs.
- Alloy resumes log delivery after restart without creating uncontrolled duplicates.
- Restore and retention procedures are documented and tested.
