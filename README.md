# Enterprise Cloud FinOps & Governance Baseline

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4.svg?logo=terraform)](https://www.terraform.io/)
[![Main Branch Checks](https://github.com/romanbovda/cloud-finops-enterprise-baseline/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/romanbovda/cloud-finops-enterprise-baseline/actions/workflows/main.yml)

[![Infracost](https://img.shields.io/badge/FinOps-Infracost-00c7b7.svg?logo=infracost)](https://www.infracost.io/)
[![Security](https://img.shields.io/badge/DevSecOps-Trivy_%7C_Checkov-000000.svg?logo=security)](https://trivy.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An enterprise-grade **Cloud FinOps Baseline** designed to enforce strict financial controls, tagging policies, and proactive anomaly detection across AWS environments. This repository serves as a reference architecture for organizations seeking to implement Shift-Left FinOps and DevSecOps within their Infrastructure as Code (IaC) pipelines.

## Business Value for Executives & CTOs

In modern cloud infrastructures, unpredictable costs and compliance gaps are significant risks. This baseline directly addresses these challenges:

- **Cost Predictability & Shift-Left FinOps**: By integrating `infracost` into the CI/CD pipeline, financial impact is calculated and reviewed on every Pull Request *before* deployment. Engineers see the price tag of their architectural decisions instantly.

  ![Infracost PR Report](docs/assets/infracost_report.png)
- **Automated Cost Governance**: Prevents runaway costs by hard-blocking the deployment of untagged or non-compliant resources at the AWS Organizations level using Service Control Policies (SCPs). If a resource cannot be attributed to a cost center, it cannot be built.
- **Proactive Cost Anomaly Detection**: Leverages AWS Machine Learning to instantly alert FinOps and Engineering teams the moment abnormal spending spikes occur, rather than discovering them at the end of the billing cycle.
- **Continuous Security & Compliance**: Automated scanning via `trivy`, `checkov`, and `tflint` ensures that all infrastructure code adheres to SOC2 compliance and enterprise security baselines.

## Repository Structure

- `modules/`: Strictly typed, highly reusable Terraform modules for AWS FinOps and Governance.
- `examples/production-baseline/`: A fully functional, production-ready configuration demonstrating how to consume the modules.
- `.github/workflows/`: Enterprise CI/CD pipelines incorporating automated DevSecOps and FinOps checks.

## Quick Start

To deploy this baseline in your environment, refer to the [Production Baseline Example](examples/production-baseline/README.md) for detailed deployment instructions.

## CI/CD Pipeline Capabilities

Our GitHub Actions pipeline enforces a zero-trust approach to infrastructure changes:

![DevSecOps Pipeline Checks](docs/assets/pipeline_checks.png)

1. **Static Code Analysis**: Enforces Terraform formatting and static linting (`tflint`).
2. **Security Scanning**: Deep inspection of Terraform code for misconfigurations (`trivy`, `checkov`).
3. **FinOps Breakdown**: Generates a detailed cost estimate for the proposed changes and comments directly on the PR.

## Author

**Roman Bovda**
Cloud FinOps & Infrastructure Expert
[LinkedIn](https://www.linkedin.com/in/roman-bovda-918659102/) | [GitHub](https://github.com/romanbovda)
