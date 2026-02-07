# OpenShift Validated Reference Design for Enterprise AI

> **IMPORTANT NOTE**: This project is a community-driven reference design and is **NOT officially supported by Red Hat**. It is provided as-is for validation and reference purposes. For production deployments, please consult Red Hat documentation and support channels.

## Overview

This reference configuration uses the [kube-compare](https://github.com/openshift/kube-compare) tool to validate a complete Red Hat OpenShift AI deployment, ensuring all required components are properly configured for production-ready Enterprise AI workloads.

The reference validates the following infrastructure layers:

- **Foundation Operators** (mandatory): Node Feature Discovery (NFD) and Kernel Module Management (KMM)
- **Storage Backends** (conditional): Logical Volume Manager Storage (LVMS) or alternative storage solutions
- **GPU Infrastructure** (requires at least one): NVIDIA GPU Operator or AMD GPU Operator
- **OpenShift AI Platform** (mandatory): OpenShift AI Operator, Service Mesh, Serverless, and Authorino

## Architecture

The reference uses kube-compare V2 format with logical matching strategies:

- **`allOf`**: Mandatory components that must all be present (Foundation Operators, OpenShift AI Platform)
- **`allOrNoneOf`**: Complete stack validation - either all components present or none (Storage, GPU vendors)

This approach enforces architectural requirements while allowing configuration flexibility for different infrastructure scenarios.

## Structure

```yaml
.
├── metadata.yaml              # Main kube-compare configuration
├── common/
│   ├── operators/            # Foundation operators (NFD, KMM)
│   ├── platform/             # OpenShift AI platform components
│   └── storage/              # Storage backend configurations (LVMS)
├── vendors/
│   ├── nvidia/               # NVIDIA GPU operator
│   └── amd/                  # AMD GPU operator
└── docs/
    ├── foundation-operators.md    # Foundation layer coding standards
    ├── storage-backends.md        # Storage configuration guidelines
    ├── gpu-infrastructure.md      # GPU vendor selection and setup
    └── openshift-ai.md            # Platform component requirements
```

## Prerequisites

- Red Hat OpenShift 4.20 or later
- [kube-compare](https://github.com/openshift/kube-compare) CLI tool installed
- Cluster admin access for validation
- GPU hardware (NVIDIA or AMD) for AI/ML acceleration

## Usage

### Compare Against Live Cluster

Compare your running OpenShift cluster against the reference configuration:

```bash
oc cluster-compare \
  -r https://raw.githubusercontent.com/leo8a/openshift-reference-enterprise-ai/refs/heads/main/metadata.yaml
```

### Compare with Local must-gather Files

Validate using must-gather output for offline analysis:

```bash
oc cluster-compare \
  -r https://raw.githubusercontent.com/leo8a/openshift-reference-enterprise-ai/refs/heads/main/metadata.yaml \
  -f "must-gather.local.*/*/cluster-scoped-resources","must-gather.local.*/*/namespaces" \
  -R
```

## Validation Strategy

The reference enforces the following validation logic:

1. **Foundation Operators**: Both NFD and KMM must be present
2. **Storage**: LVMS stack must be complete if deployed, or alternative storage must be available
3. **GPU Infrastructure**: At least one GPU vendor operator (NVIDIA or AMD) must be fully deployed
4. **OpenShift AI Platform**: All four components (RHOAI, Service Mesh, Serverless, Authorino) must be present

## Customization

Refer to the documentation in `docs/` for detailed coding standards and customization guidelines:

- Modify component versions in subscription manifests
- Adjust storage configurations for your infrastructure
- Configure GPU settings for specific hardware
- Customize DataScienceCluster settings for workload requirements

## Contributing

Contributions are welcome! Please ensure:

- All changes follow the coding standards documented in `docs/`
- New components include appropriate validation strategy (`allOf`, `allOrNoneOf`, etc.)
- Component descriptions clearly explain purpose and dependencies
- Changes are tested with kube-compare validation

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## References

- [kube-compare Documentation](https://github.com/openshift/kube-compare)
- [kube-compare Reference Config Guide V2](https://github.com/openshift/kube-compare/blob/main/docs/reference-config-guide-v2.md)
- [Red Hat OpenShift AI](https://www.redhat.com/en/technologies/cloud-computing/openshift/openshift-ai)
- [AMD GPU Operator](https://instinct.docs.amd.com/projects/gpu-operator/en/latest/index.html)
- [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/)
