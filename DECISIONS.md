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

## Decision 005 — Deploy SignalOps on AWS EC2

**Date:** 2026-07-24

### Decision

Deploy SignalOps to an AWS EC2 instance instead of running it only on a local development machine.

### Rationale

Running the platform locally was sufficient for initial development, but it could not demonstrate how the system behaves in a cloud environment. Deploying to AWS made it possible to validate the complete observability stack under conditions that are much closer to production.

AWS EC2 also provided an opportunity to practice infrastructure provisioning, Linux administration, Docker deployment, networking, remote troubleshooting, and operational debugging. These are essential cloud engineering skills that cannot be fully demonstrated in a local environment.

Deploying to EC2 allowed the platform to collect live infrastructure metrics, centralize application logs, and expose Grafana dashboards over the network, providing confidence that every component worked together outside the development environment.

### Alternatives Considered

* Continue developing only on a local Ubuntu machine.
* Deploy the platform to Amazon ECS.
* Deploy directly to Kubernetes.

### Outcome

Accepted.

SignalOps now runs successfully on AWS EC2 with Prometheus, Grafana, Loki, Promtail, Node Exporter, and cAdvisor operating as an integrated observability platform.

### Consequences

The project now reflects a deployment model that is closer to real production environments and demonstrates practical cloud engineering skills beyond local development.

Choosing EC2 also establishes a solid foundation for future phases, including automated deployments, infrastructure scaling, security hardening, and migration to more advanced orchestration platforms such as Kubernetes when the project reaches that stage.

## Decision 006 — Provision Infrastructure with Terraform

**Date:** 2026-07-24

### Decision

Provision AWS infrastructure with Terraform instead of creating and managing resources manually through the AWS Management Console.

### Rationale

Cloud infrastructure should be reproducible, version-controlled, and easy to review. Terraform makes it possible to define infrastructure as code, allowing environments to be created, modified, and recreated consistently from the same source files.

Using Terraform also encourages engineering best practices such as input validation, reusable variables, descriptive outputs, consistent resource tagging, and modular project organization. These practices improve maintainability as the platform grows.

Managing infrastructure in code also provides a complete history of infrastructure changes through Git, making collaboration and troubleshooting easier than relying on manual configuration.

### Alternatives Considered

* Create resources manually through the AWS Management Console.
* Use AWS CloudFormation.
* Configure infrastructure with shell scripts.

### Outcome

Accepted.

AWS infrastructure for SignalOps is provisioned and managed with Terraform. The project follows a structured layout with separate configuration files for networking, compute, security, variables, outputs, and shared values, making the infrastructure easier to understand and maintain.

### Consequences

Infrastructure changes are made by updating Terraform configuration rather than modifying resources directly in the AWS Console. This improves consistency across environments, reduces configuration drift, and provides a repeatable deployment process.

The AWS Management Console is now used primarily for verification, monitoring, and debugging, while Terraform remains the authoritative source for infrastructure configuration.

## Decision 007 — Use Prometheus for Metrics Collection

**Date:** 2026-07-24

### Decision

Use Prometheus as the primary metrics collection system for SignalOps.

### Rationale

The objective of SignalOps is to provide real-time visibility into the health and performance of cloud infrastructure. Prometheus is designed specifically for collecting, storing, and querying time-series metrics, making it well suited for monitoring infrastructure and containerized workloads.

Prometheus integrates naturally with Node Exporter and cAdvisor, allowing the platform to collect CPU, memory, disk, network, and container metrics through a consistent pull-based model. Its query language, PromQL, also enables flexible analysis and alerting as the platform evolves.

Choosing Prometheus aligns with the project's goal of building an enterprise-style observability platform using widely adopted open-source technologies.

### Alternatives Considered

* Amazon CloudWatch
* Datadog
* InfluxDB

### Outcome

Accepted.

Prometheus continuously collects infrastructure and container metrics from Node Exporter and cAdvisor. These metrics serve as the foundation for dashboards in Grafana and will support automated alerting in the next phase of the project.

### Consequences

SignalOps now has a centralized and extensible metrics platform that supports visualization, historical analysis, and alerting without introducing vendor lock-in. Future monitoring capabilities can be added by exposing new Prometheus-compatible metrics rather than replacing the monitoring stack.


## Decision 008 — Use Loki for Centralized Log Management

**Date:** 2026-07-25

### Decision

Use Grafana Loki as the centralized logging solution for SignalOps.

### Rationale

Metrics explain that a problem exists, but logs explain why it exists. SignalOps requires both to provide complete observability.

Loki integrates directly with Grafana and stores log metadata as labels instead of indexing the full log content. This architecture reduces operational complexity while providing efficient log querying through LogQL. It also aligns well with the project's goal of building a lightweight, production-oriented observability platform.

### Alternatives Considered

* Elasticsearch, Logstash, and Kibana (ELK)
* OpenSearch
* Splunk

### Outcome

Accepted.

Loki serves as the centralized log store for SignalOps, receiving logs from Promtail and making them available through Grafana.

### Consequences

SignalOps can correlate infrastructure metrics with application logs from a single interface, improving troubleshooting and reducing the time required to investigate incidents.

---

## Decision 009 — Use Promtail for Log Collection

**Date:** 2026-07-25

### Decision

Use Promtail to collect and forward logs to Loki.

### Rationale

Promtail is designed specifically for Loki and provides automatic service discovery, label generation, and log forwarding with minimal configuration. It integrates naturally with Docker and simplifies centralized log collection.

### Alternatives Considered

* Fluent Bit
* Fluentd
* Filebeat

### Outcome

Accepted.

Promtail collects container logs and forwards them to Loki for centralized storage and querying.

### Consequences

Application and container logs are automatically collected without requiring changes to individual services, making the logging pipeline easier to maintain and extend.

---

## Decision 010 — Use cAdvisor for Container Metrics

**Date:** 2026-07-26

### Decision

Use cAdvisor to collect container-level resource metrics.

### Rationale

Node Exporter provides host operating system metrics but does not expose detailed container statistics. cAdvisor fills this gap by collecting CPU, memory, filesystem, and network metrics for individual containers.

Using both exporters provides complete visibility into both the host system and the workloads running on it.

### Alternatives Considered

* Node Exporter only
* Docker CLI statistics
* Container Insights

### Outcome

Accepted.

cAdvisor is integrated with Prometheus and provides container-specific metrics for Grafana dashboards.

### Consequences

SignalOps can monitor individual containers in addition to overall host health, making performance analysis and troubleshooting more effective.

---

## Decision 011 — Provision Grafana Automatically

**Date:** 2026-07-27

### Decision

Provision Grafana data sources through configuration files instead of creating them manually through the user interface.

### Rationale

Infrastructure should be reproducible. Automatically provisioning data sources ensures every deployment starts with the same configuration, eliminates manual setup, and reduces deployment errors.

### Alternatives Considered

* Configure Grafana manually after deployment.

### Outcome

Accepted.

Grafana automatically provisions Prometheus and Loki during startup.

### Consequences

New deployments require little or no manual configuration, improving consistency and simplifying future automation.

---

## Decision 012 — Prioritize Root Cause Analysis Over Temporary Fixes

**Date:** 2026-07-28

### Decision

Resolve failures by identifying and correcting the underlying cause instead of applying temporary workarounds.

### Rationale

During deployment, Loki failed to start because its configuration file had been unintentionally overwritten during local development. Rather than masking the issue, each component was validated independently until the actual cause was identified.

This approach produces more reliable systems and prevents recurring failures.

### Alternatives Considered

* Apply temporary configuration changes until the service started.
* Rebuild the stack without identifying the failure.

### Outcome

Accepted.

The configuration issue was corrected, synchronized across the local repository, GitHub, and AWS, and the observability platform was fully restored.

### Consequences

The project established a repeatable debugging methodology based on verification, isolation, and root cause analysis. This approach will continue to guide future troubleshooting and operational work.
