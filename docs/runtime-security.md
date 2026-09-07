# Runtime security and admission policy

This phase adds layered controls around workload admission, runtime behavior and security investigation.

## Control layers

1. Kubernetes Pod Security Admission provides namespace-level baseline or restricted controls.
2. Kyverno evaluates organization-specific workload policy and produces policy reports.
3. Falco observes Linux kernel activity on every node and detects suspicious runtime behavior.
4. Read-only audit RBAC provides investigation access without mutation privileges.
5. Prometheus and Alertmanager carry policy-engine and runtime-security health signals.

Admission controls reduce unsafe configuration. Runtime detection identifies behavior that static manifests cannot
predict. Neither layer replaces vulnerability management, identity controls or incident response.

## Falco Operator

The Falco Operator is the recommended Kubernetes-native deployment path. The supplied `Falco` resource creates a
DaemonSet and relies on the operator-pinned Falco version and default modern eBPF engine.

The `runtime-security` namespace intentionally uses the privileged Pod Security profile because Falco needs host
and kernel visibility. No application workload belongs in that namespace.

Before rollout, verify BTF and eBPF support on every K3s node. Test rule delivery, event throughput, dropped-event
metrics and alert routing under representative load.

## Kyverno

The supplied values use highly available controller counts suitable for a three-node cluster. Policies begin in
`Audit` mode and target workload namespaces rather than system or security namespaces.

Included policies report:

- privileged containers;
- missing or mutable image tags;
- application containers without CPU and memory requests and limits.

Review PolicyReports, resolve existing violations and define a time-bound exception process. Promote one policy at
a time from `Audit` to `Enforce` only after proving that controllers, upgrades and emergency operations remain
safe.

## Audit role

`platform-security-auditor` grants get, list and watch access to workload, network and policy-report metadata. It
does not include Secrets and it is intentionally not bound to any user, group or ServiceAccount.

Create environment-specific bindings outside this public repository after identity review and approval.

## Operational gates

Before production approval, prove:

- Falco runs on every Linux node and survives a rolling node restart.
- A controlled suspicious-command test creates an event and reaches the incident channel.
- Kyverno remains available during a node loss.
- Audit policies report known test violations without blocking workloads.
- Enforced policies reject only the intended test resources.
- Exceptions have an owner, expiry and written reason.
- Security auditors cannot read Secrets or mutate resources.
- Detection rules, policies and operator versions have documented upgrade and rollback procedures.
