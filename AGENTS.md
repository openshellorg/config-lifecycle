# config-lifecycle

D library implementing OpenShellOrg **Config Lifecycle Management**: never stop detecting expired config keys.

- Spec: https://docs.opensh.org/open-shell-org/standard-config-lifecycle-management.html
- Registry: DUB (`config-lifecycle`) — publish when ready; local path OK for co-dev

## Agents

Keep catalogs complete. Prefer status transitions over deleting key rows.
Demo: `dub run --config=demo -- <config-file>`.
