---
id: SPEC-0001
title: Cluster Management MVP
status: draft
last_updated: 2026-03-24
related_contexts:
  - Infrastructure
  - Accounts
related_entities:
  - Cluster
related_workflows:
  - Provision Cluster
---

# Cluster Management MVP

> Users can create, view, and delete clusters through the dashboard.

---

## Problem

The platform needs a foundational way for users to manage infrastructure.
Without cluster management, no other features (deployments, monitoring) can work.

---

## Outcome

After this is implemented:

- A user can create a cluster with a name and region.
- A user can see all their clusters and their current status.
- A user can delete a cluster that has no active deployments.
- Cluster status updates appear in real-time without page refresh.

---

## Scope

- Cluster CRUD (create, read, delete — update deferred).
- Real-time status via PubSub.
- Basic validation (unique name per team, valid region).

---

## Non-Goals

- Node management within clusters (separate spec).
- Scaling clusters up/down.
- Multi-region clusters.

---

## Acceptance Examples

**Creating a cluster:**

1. Given a logged-in user on the clusters page,
2. When they submit the form with name "production" and region "us-east-1",
3. Then a cluster appears in the list with status "provisioning",
4. And it transitions to "running" when provisioning completes.

**Deleting a cluster:**

1. Given a cluster with no active deployments,
2. When the user clicks delete and confirms,
3. Then the cluster is removed from the list.

**Preventing invalid deletion:**

1. Given a cluster with active deployments,
2. When the user attempts to delete it,
3. Then the system shows an error explaining deployments must be removed first.

---

## Open Questions

- Which regions should be available at launch?
- What's the maximum number of clusters per team?
