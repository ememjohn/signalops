# SignalOps Technical Documentation


1. Overview

SignalOps is a containerized infrastructure observability platform designed to monitor the health, resource utilization, and operational state of cloud-hosted workloads.

The platform runs on an AWS EC2 instance and uses Prometheus as its metrics collection and alerting engine. Grafana provides visualization and operational dashboards, while Node Exporter and cAdvisor expose infrastructure and container metrics respectively. Loki and Promtail provide centralized log collection, and Alertmanager handles alert routing.

Terraform manages the AWS infrastructure, while Docker Compose manages the observability services running on the host.

The system provides visibility across four primary areas:

Host infrastructure
Docker containers
Application and system metrics
Operational logs and alerts

The architecture is designed to keep infrastructure provisioning, observability configuration, and application runtime concerns separated.

2. Architecture

SignalOps consists of the following major layers:
                         AWS
                          │
                          ▼
                  ┌───────────────┐
                  │  EC2 Instance │
                  │   t3.micro    │
                  └───────┬───────┘
                          │
                    Docker Engine
                          │
        ┌─────────────────┼──────────────────┐
        │                 │                  │
        ▼                 ▼                  ▼
 ┌────────────┐    ┌──────────────┐     ┌────────────┐
 │ Prometheus │    │   Grafana    │     │    Loki    │
 │   Metrics  │    │ Visualization│     │    Logs    │
 └─────┬──────┘    └──────┬───────┘     └──────┬─────┘
       │                   │                  │
       │                   │                  │
       ▼                   │                  ▼
 ┌─────────────┐           │           ┌────────────┐
 │Node Exporter│           │           │  Promtail  │
 └─────────────┘           │           └────────────┘
                           │
       ┌───────────────────┘
       │
       ▼
 ┌────────────┐
 │  cAdvisor  │
 │ Containers │
 └────────────┘

              Prometheus
                   │
                   ▼
             Alert Rules
                   │
                   ▼
             Alertmanager

The architecture separates metric collection, metric storage and evaluation, visualization, logging, and alert routing.

3. Technology Stack
Component	Technology	Responsibility
Cloud infrastructure	AWS EC2	Hosts the observability platform
Infrastructure as Code	Terraform	Provisions and manages AWS resources
Container runtime	Docker	Runs SignalOps services
Container orchestration	Docker Compose	Defines and manages the observability stack
Metrics collection	Prometheus	Scrapes, stores, queries, and evaluates metrics
Host metrics	Node Exporter	Exposes Linux host metrics
Container metrics	cAdvisor	Exposes Docker container metrics
Visualization	Grafana	Provides dashboards and operational visibility
Log collection	Promtail	Collects and forwards logs
Log storage	Loki	Stores and queries logs
Alert routing	Alertmanager	Processes and routes Prometheus alerts
CI	GitHub Actions	Validates repository changes automatically
Source control	Git/GitHub	Stores source code and configuration
4. AWS Infrastructure

SignalOps runs on an Amazon EC2 instance.

The current deployment uses an EC2 t3.micro instance. The instance provides the compute environment for the Docker-based observability stack.

The infrastructure includes:

EC2 compute
VPC networking
Security group configuration
Instance configuration
IAM-related infrastructure where required
Terraform-managed resources

Terraform keeps the infrastructure definition in version control so the environment can be recreated or modified without manually configuring AWS resources.

The Terraform configuration is organized around infrastructure concerns rather than individual deployment commands.

Terraform structure

terraform/
├── compute.tf
├── locals.tf
├── main.tf
├── network.tf
├── outputs.tf
├── provider.tf
├── security.tf
├── variables.tf
├── terraform.tfvars.example
└── scripts/
    └── user_data.sh

The environments/ directory provides a structure for environment-specific configuration.

5. Infrastructure Provisioning

Terraform handles infrastructure provisioning through declarative configuration.

The workflow is:
Terraform configuration
        │
        ▼
terraform plan
        │
        ▼
Review infrastructure changes
        │
        ▼
terraform apply
        │
        ▼
AWS resources
        │
        ▼
EC2 instance

Terraform configuration defines the desired infrastructure state. Terraform then compares that desired state with the current state and determines the changes required.

This approach reduces manual configuration and makes infrastructure changes reviewable and repeatable.

Terraform state remains a local deployment concern and is excluded from source control.

6. Docker Architecture

SignalOps runs its observability services as containers.

Docker Compose defines the services, networks, volumes, ports, and service relationships required by the platform.

The stack includes:

Prometheus
Grafana
Node Exporter
cAdvisor
Loki
Promtail
Alertmanager

The services communicate through the Docker network created for the SignalOps deployment.

This allows services to reference each other using Docker service names rather than relying on hard-coded container IP addresses.

For example, Prometheus can scrape:

node-exporter:9100
cadvisor:8080

rather than depending on dynamically assigned container addresses.

7. Prometheus

Prometheus serves as the central metrics engine for SignalOps.

Its responsibilities include:

Scraping metrics from monitored services.
Storing time-series data.
Executing PromQL queries.
Evaluating alerting rules.
Providing metrics to Grafana.
Reporting target health.

The Prometheus configuration is located at:

prometheus/prometheus.yml

Alert rules are stored separately:

prometheus/rules/alerts.yml

This separation keeps collection configuration independent from alerting logic.

8. Metrics Collection

SignalOps collects metrics from multiple sources.

Prometheus

Prometheus exposes its own operational metrics.

localhost:9090/metrics
Node Exporter

Node Exporter exposes Linux host-level metrics.

node-exporter:9100

These metrics include information about:

CPU utilization
CPU load
memory
filesystem usage
disk activity
network traffic
system uptime
CPU cores

The Node Exporter dashboard provides a direct view of the EC2 host's operating condition.

cAdvisor

cAdvisor exposes container-level metrics.

cadvisor:8080

These metrics provide visibility into Docker workloads, including:

Container CPU consumption
Container memory usage
Container network activity
Container resource utilization
Running container state

This gives SignalOps visibility at both the host level and container level.

9. Prometheus Target Health

Prometheus continuously checks whether configured monitoring targets are reachable.

The SignalOps deployment monitors:

prometheus
node-exporter
cadvisor

A healthy deployment should show these targets as UP.

Example:

cadvisor       UP
node-exporter  UP
prometheus     UP

Target health is important because a dashboard can appear operational while the underlying metric source has stopped reporting.

SignalOps therefore treats target availability as an operational signal in its own right.

10. Grafana

Grafana provides the primary visualization layer for SignalOps.

The Grafana instance connects to Prometheus as its metrics data source and uses the collected time-series data to render infrastructure dashboards.

The primary dashboard is:

SignalOps Infrastructure Dashboard

The dashboard provides visibility into areas including:

CPU utilization
Memory usage
Disk usage
Network receive traffic
Network transmit traffic
Running containers

The project also includes a Node Exporter based infrastructure dashboard for detailed host-level analysis.

11. Grafana Provisioning

Grafana configuration is maintained in the repository rather than being treated as an entirely manual configuration.

The provisioning structure is:
grafana/
└── provisioning/
    ├── dashboards/
    │   ├── dashboard.yml
    │   └── signalops-infrastructure-dashboard.json
    └── datasources/
        └── prometheus.yml

The Prometheus data source is provisioned through:

grafana/provisioning/datasources/prometheus.yml

The dashboard definition is stored as JSON:

grafana/provisioning/dashboards/signalops-infrastructure-dashboard.json

This allows the dashboard configuration to remain part of the project source code.

If Grafana needs to be recreated in another environment, the dashboard definition can be provisioned again rather than manually rebuilding every panel.

12. Loki and Promtail

SignalOps includes a centralized logging pipeline.
Application / Container Logs
            │
            ▼
         Promtail
            │
            ▼
           Loki
            │
            ▼
         Grafana

Promtail collects logs and forwards them to Loki.

Loki stores the logs and provides a query interface that Grafana can use for investigation.

The configuration files are:

loki/loki-config.yml

and:

promtail/promtail-config.yml

This separates log collection from log storage.

13. Alerting

SignalOps uses Prometheus alerting rules to identify infrastructure conditions that require attention.

The alert rules are defined in:

prometheus/rules/alerts.yml

The configured rules include:

InstanceDown
HighCPUUsage
HighMemoryUsage
DiskUsageHigh
cAdvisorDown
InstanceDown

Detects a monitoring target that is no longer available.

HighCPUUsage

Identifies sustained CPU utilization above the configured threshold.

HighMemoryUsage

Identifies sustained memory utilization above the configured threshold.

DiskUsageHigh

Identifies high filesystem utilization.

cAdvisorDown

Detects when the container metrics endpoint becomes unavailable.

These rules allow SignalOps to move beyond passive dashboards and provide automated detection of infrastructure conditions.

14. Alertmanager

Alertmanager handles alerts generated by Prometheus.

The configuration is stored at:

alertmanager/alertmanager.yml

The responsibility of Alertmanager is separate from Prometheus rule evaluation.

Prometheus determines that an alert condition exists.

Alertmanager handles the subsequent alert management and routing workflow.

This separation allows the monitoring engine and notification layer to evolve independently.

15. Monitoring Data Flow

A typical host metric follows this path:

EC2 Linux Host
      │
      ▼
Node Exporter
      │
      ▼
Prometheus
      │
      ├──────────────► Alert Rules
      │                     │
      │                     ▼
      │               Alertmanager
      │
      ▼
   Grafana
      │
      ▼
Infrastructure Dashboard
Container metrics follow a similar path:
Docker Containers
       │
       ▼
    cAdvisor
       │
       ▼
   Prometheus
       │
       ▼
    Grafana

Logs follow a separate pipeline:
Container / System Logs
          │
          ▼
       Promtail
          │
          ▼
         Loki
          │
          ▼
       Grafana

Container / System Logs
          │
          ▼
       Promtail
          │
          ▼
         Loki
          │
          ▼
       Grafana

This separation allows metrics and logs to use purpose-built collection and storage systems while maintaining a unified visualization layer.

16. Persistent Storage

SignalOps uses persistent Docker volumes for stateful services.

The deployment includes persistent storage for services such as:

signalops_grafana-storage
signalops_prometheus-data
signalops_loki-data
signalops_alertmanager-data

Persistent volumes prevent application state from depending entirely on the lifecycle of individual containers.

For example, recreating the Grafana container does not inherently mean that the Grafana database disappears when its persistent volume remains intact.

17. Networking

SignalOps services communicate through the Docker Compose network.

Service discovery uses Docker's internal DNS and service names.

Examples include:

prometheus:9090
grafana:3000
node-exporter:9100
cadvisor:8080
loki:3100

This approach avoids unnecessary exposure of internal service ports to the public internet.

Only services that require external access should expose host ports.

The AWS security group provides the outer network boundary for the EC2 instance.

18. Security Considerations

Security is treated as an infrastructure concern rather than an afterthought.

Key considerations include:

Restricting public network access through AWS security groups.
Avoiding unnecessary public exposure of monitoring endpoints.
Keeping sensitive Terraform variables out of source control.
Excluding Terraform state and local credentials from Git.
Avoiding hard-coded credentials in application configuration.
Keeping Node Exporter and internal observability services on the private Docker network where possible.
Using infrastructure-as-code definitions that can be reviewed before deployment.

The repository contains:

terraform/terraform.tfvars.example

rather than committing environment-specific sensitive values.

The project's .gitignore also excludes local Terraform state and other environment-specific files.

19. CI/CD

SignalOps uses GitHub Actions for continuous integration.

The workflow is located at:

.github/workflows/signalops-ci.yml

The CI pipeline validates repository changes automatically when changes are pushed to GitHub.

The workflow provides an automated quality gate before changes are considered complete.

The repository therefore contains both the infrastructure implementation and the automation required to validate changes.

20. Repository Architecture

The repository follows a separation-of-concerns structure:
SignalOps/
│
├── alertmanager/
│   └── alertmanager.yml
│
├── docs/
│   ├── architecture/
│   ├── runbooks/
│   └── screenshots/
│
├── grafana/
│   └── provisioning/
│
├── loki/
│   └── loki-config.yml
│
├── prometheus/
│   ├── prometheus.yml
│   └── rules/
│
├── promtail/
│   └── promtail-config.yml
│
├── terraform/
│   ├── compute.tf
│   ├── network.tf
│   ├── security.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── scripts/
│
├── .github/
│   └── workflows/
│
├── DECISIONS.md
├── docker-compose.yml
├── LICENSE
└── README.md

Each directory owns a specific infrastructure or application concern.

This structure keeps the repository maintainable as the platform grows.

21. Operational Workflow

A typical SignalOps deployment follows this sequence:

1. Provision AWS infrastructure
              ↓
2. Initialize EC2 host
              ↓
3. Install and configure Docker
              ↓
4. Deploy SignalOps services
              ↓
5. Prometheus discovers monitoring targets
              ↓
6. Metrics begin flowing
              ↓
7. Grafana visualizes metrics
              ↓
8. Alert rules evaluate metrics
              ↓
9. Alertmanager processes alerts
              ↓
10. Loki and Promtail provide log visibility

This workflow creates a complete observability path from infrastructure provisioning to operational monitoring.

22. Failure Detection

SignalOps is designed to detect failures at multiple levels.

Target failure

If Node Exporter becomes unavailable:

Node Exporter
      ↓
Prometheus target = DOWN
      ↓
InstanceDown
Container monitoring failure

If cAdvisor becomes unavailable:

cAdvisor
   ↓
Prometheus target = DOWN
   ↓
cAdvisorDown
Resource exhaustion

If CPU, memory, or disk utilization exceeds configured thresholds:

Infrastructure Metric
        ↓
Prometheus Rule Evaluation
        ↓
Alert

This provides operational visibility before and during infrastructure failures.

23. Observability Model

SignalOps follows a three-layer observability model:

Metrics

Prometheus collects numerical time-series data from infrastructure and containers.

Examples:

CPU utilization
Memory utilization
Filesystem utilization
Network traffic
Container resource usage
Target availability
Logs

Promtail collects logs and sends them to Loki.

Logs provide contextual information that metrics alone cannot provide.

Visualization and Investigation

Grafana provides a unified interface for viewing metrics and logs.

This allows an operator to move from:

What is happening?

to:

Where is it happening?

and then:

Why is it happening?
24. Design Decisions

The major architectural decisions for SignalOps are documented separately in:

DECISIONS.md

That document records the reasoning behind important technology and architecture choices.

Keeping decisions separate from technical implementation documentation prevents the technical reference from becoming a historical decision log.

25. Reliability Considerations

SignalOps separates monitoring components by responsibility.

Prometheus handles metrics.

Grafana handles visualization.

Node Exporter handles host metrics.

cAdvisor handles container metrics.

Promtail handles log collection.

Loki handles log storage.

Alertmanager handles alert management.

This separation reduces coupling between components and makes individual services easier to replace, troubleshoot, or scale.

The use of Docker Compose also provides a consistent service definition across environments.

26. Deployment Model

The current architecture is intentionally compact.

AWS EC2
   │
   └── Docker
       ├── Prometheus
       ├── Grafana
       ├── Node Exporter
       ├── cAdvisor
       ├── Loki
       ├── Promtail
       └── Alertmanager

This model is appropriate for a portfolio-grade observability platform and a small production-style environment where simplicity and operational clarity matter.

A future production deployment could separate monitoring components across multiple compute nodes or managed services depending on scale and availability requirements.

27. Future Evolution

Potential future improvements include:

High-availability Prometheus
Remote metric storage
Managed Grafana
Object storage for long-term metrics
Multi-node monitoring
Kubernetes monitoring
Additional alert notification channels
Infrastructure cost monitoring
SLO and SLA tracking
Automated remediation workflows
Distributed tracing

These improvements are outside the scope of the current implementation.

The current architecture establishes the core observability capabilities required for infrastructure monitoring.

28. Summary

SignalOps provides an infrastructure observability platform built around open-source monitoring technologies and AWS infrastructure.

The platform combines:

Terraform
   +
AWS EC2
   +
Docker
   +
Prometheus
   +
Node Exporter
   +
cAdvisor
   +
Grafana
   +
Loki
   +
Promtail
   +
Alertmanager
   +
GitHub Actions

The result is a reproducible monitoring environment capable of collecting infrastructure and container metrics, visualizing operational state, collecting logs, and detecting infrastructure failures through automated alert rules.

The project keeps infrastructure configuration, monitoring configuration, dashboards, alert rules, and deployment automation in source control. This makes the system reproducible, reviewable, and suitable for continued development.