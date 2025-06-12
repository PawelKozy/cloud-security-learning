# ☁️ Cloud Security Learning Lab

This repository documents my hands-on journey in cloud and application security across major platforms like **AWS**, **Azure**, and **GCP**. It blends practical experiments, real-world attack-defense simulations, detection engineering, and automation workflows into a structured and evolving knowledge base.

All code, notes, and labs are written from scratch — no licensed or proprietary content is included.

---

## 📁 Repository Structure

```
cloud-security-learning/
├── AWS/
├── Azure/
├── GCP/
├── containers/
├── learning-log.md
└── README.md
```
---

## 🔍 Topics Covered

- Identity and access abuse detection
- Container image scanning and hardening (ECR, ACR)
- Infrastructure misconfiguration and runtime hardening
- Automation with Python (Boto3), AWS CLI, and Terraform
- Cloud-native incident response (IR) playbooks
- Threat modeling and defensive baselining
- Telemetry design for multi-cloud environments
- Working with services like CloudTrail, GuardDuty, Azure Sentinel, etc.

---

## 🛠️ Labs & Tools

This repo includes real-world scenarios where I:

- Simulate cloud attacks (e.g., IAM privilege escalation, SSRF)
- Write detection-as-code logic in SQL/KQL
- Automate remediation tasks using Lambda, Logic Apps, and SOAR APIs
- Deploy Terraform-managed infrastructure (with security focus)
- Use Boto3 scripts for ECR scanning and secret rotation


## Tools/

- [Trivy](./Tools/trivy/)
- [Clair](./Tools/clair/)
- [Checkov](./Tools/checkov/)
- [Osquery](./Tools/osquery/)
- [Falco](./Tools/falco/)
- [Grype](./Tools/grype/)

---

## 🚧 Work in Progress

This is an evolving project. The focus is on building reusable knowledge blocks, rather than showcasing polished products. Daily logs are updated in [`learning-log.md`](./learning-log.md).

---

## 🙋‍♂️ Why This Repo?

- **To stay sharp** in an ever-evolving threat landscape    
- **To bridge gaps** between theory and practice in cloud security    
- **To demonstrate practical expertise** through reproducible labs and detection logic    
