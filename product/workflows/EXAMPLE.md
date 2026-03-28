---
workflow: Provision Cluster
status: candidate
primary_context: Infrastructure
last_updated: 2026-03-24
---

# Provision Cluster

> Creates a new cluster and waits for infrastructure to become ready.

---

## Trigger

User requests a new cluster through the dashboard or API.

---

## Participants

- **User** — initiates the request
- **Infrastructure context** — validates and persists the cluster
- **ProvisionClusterWorker** — background job that provisions actual infrastructure
- **PubSub** — broadcasts status changes to connected users

---

## Happy Path

1. User submits cluster creation form with name and region.
2. Infrastructure context validates input, inserts cluster with status `provisioning`.
3. Oban job `ProvisionClusterWorker` is enqueued in the same transaction.
4. PubSub broadcasts `{:cluster_created, cluster}`.
5. Worker provisions infrastructure (calls external API).
6. Worker updates cluster status to `running`.
7. PubSub broadcasts `{:cluster_status_changed, cluster}`.
8. User sees the cluster transition to running in real-time.

---

## Failure Paths

**Provision fails:**

1. Worker receives error from infrastructure API.
2. Worker updates cluster status to `failed`.
3. PubSub broadcasts the status change.
4. User sees failure with option to retry.

**Provision times out:**

1. Worker reaches max attempts (configured in Oban).
2. Cluster remains in `provisioning` — a cleanup job detects stale clusters.

---

## Events

| Event | Topic | Payload |
|---|---|---|
| `{:cluster_created, cluster}` | `team:{team_id}` | Full cluster struct |
| `{:cluster_status_changed, cluster}` | `team:{team_id}` | Full cluster struct |

---

## Open Questions

- What timeout is appropriate for provisioning?
- Should we support partial provisioning (some nodes up, some failed)?
