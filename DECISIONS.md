# SignalOps Engineering Decisions

This document records important technical decisions made during the development of SignalOps.

The goal is to document not only *what* was chosen, but *why* it was chosen, along with alternatives that were considered.

---

## Decision 001 — Build Incrementally

**Date:** 2026-07-20

### Decision

Build SignalOps one service at a time instead of starting with a complete monitoring stack.

### Rationale

Adding Prometheus, Node Exporter, Grafana, and Alertmanager together makes troubleshooting more difficult.

Building incrementally allows each component to be verified before introducing the next dependency.

### Alternatives Considered

- Build the entire stack at once.
- Follow a tutorial exactly.

### Outcome

Accepted.

---

## Decision 002 — Use Docker Compose

**Decision**

Use Docker Compose to orchestrate local development.

### Rationale

Docker Compose provides reproducible local environments, service discovery, isolated networking, and a simple developer experience.

### Alternatives Considered

- Individual `docker run` commands.
- Installing services directly on Ubuntu.

### Outcome

Accepted.

---

## Decision 003 — Pin Image Versions

**Decision**

Use explicit container image versions instead of `latest`.

### Rationale

Pinned versions improve reproducibility and reduce unexpected breaking changes.

### Outcome

Accepted.


---

## Decision 004 — Use Official Grafana Image

### Decision

Use the official `grafana/grafana` Docker image.

### Rationale

The official Grafana image is actively maintained and recommended by the Grafana team. It supports modern provisioning, plugins, and long-term compatibility.

### Alternatives Considered

- grafana/grafana-oss
- Installing Grafana directly on Ubuntu

### Outcome

Accepted.
