# Security Policy

## Reporting a vulnerability

Please do not open a public issue for a vulnerability that could expose credentials, infrastructure access or user data.

Use the private vulnerability reporting option in this repository when available. If that option is unavailable, contact the maintainer through the professional links on [lalitjaimini.com](https://lalitjaimini.com/) without including secrets in the first message.

## Scope

This repository contains reference architecture and example configuration. It does not provide a warranty that an unmodified example is secure for a specific environment.

Before production use:

- Replace every documentation-only value
- Pin versions and image digests
- Validate the target CNI and storage behavior
- Use an external secret-management workflow
- Run policy, manifest and image scanning
- Complete a backup and restore exercise
- Review exposed services and RBAC grants

## Public-data rule

Never include real credentials, private keys, kubeconfigs, internal addresses, customer information or company-specific configuration in an issue, pull request or commit.
