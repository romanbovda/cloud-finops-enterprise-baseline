# Terraform Cloud FinOps Baseline

Welcome to the enterprise-grade **Cloud FinOps Baseline**. This repository serves as the definitive GitOps source of truth for applying strict financial controls, tagging policies, and anomaly detection across multi-cloud environments (AWS & GCP).

## 🏆 Key Capabilities

- **Automated Cost Governance**: Prevents runaway costs by hard-blocking the deployment of untagged resources using Service Control Policies (SCPs).
- **Shift-Left Cost Estimation**: Integrates `infracost` directly into the CI/CD pipeline, ensuring every Pull Request surfaces financial impact before deployment.
- **Continuous Security**: Powered by `checkov` to scan for misconfigurations and enforce SOC2 compliance.
- **Cost Anomaly Detection**: Proactive alerts directly to your FinOps and Engineering teams the moment spending anomalies are detected.

## 📁 Repository Structure

- `modules/`: Strictly typed, highly reusable Terraform modules for AWS & GCP FinOps.
- `examples/`: Production-ready configurations demonstrating how to consume the modules.
- `.github/workflows/`: Enterprise CI/CD pipelines incorporating DevSecOps and FinOps checks.

## 🚀 Getting Started

Please see the `examples/production-baseline/` directory to deploy the baseline in your environment.
