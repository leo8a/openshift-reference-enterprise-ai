# Foundation Operators - Coding Standards and Validation Requirements

## Overview

Foundation operators are critical infrastructure components that MUST be present and properly configured in all Enterprise AI clusters. These operators provide essential capabilities required by AI/ML workloads.

## Validation Policy

**MANDATORY**: All foundation operator components defined in this reference MUST be validated in every target cluster. There are no optional foundation operators - their absence indicates a non-compliant cluster configuration.

## Required Foundation Operators

This reference design requires the following operators as prerequisites for deploying the OpenShift AI platform:

### Node Feature Discovery (NFD)

**Purpose**: Detects hardware features and system configuration

**Role**: NFD is essential for identifying GPU hardware, CPU capabilities, and other hardware features that AI/ML workloads depend on. It labels nodes with discovered features, enabling proper workload scheduling.

**Required Resources**:

- Namespace configuration
- OperatorGroup definition
- Subscription manifest
- NodeFeatureRule custom resource

### Kernel Module Management (KMM)

**Purpose**: Manages out-of-tree kernel modules for GPU drivers

**Role**: KMM automates the building, signing, and deployment of kernel modules across the cluster. This is critical for GPU driver management, ensuring that the correct drivers are loaded on nodes with GPU hardware.

**Required Resources**:

- Namespace configuration
- OperatorGroup definition
- Subscription manifest

### Dependency Chain

Both NFD and KMM are required for GPU detection and driver management, forming the foundation layer that enables hardware acceleration for AI/ML workloads. NFD discovers the hardware, and KMM ensures the necessary kernel modules are loaded to utilize that hardware.

## Coding Standards

### 1. Matching Strategy

- **Required**: Use `allOf` matching strategy for foundation operators
- **Rationale**: Ensures all critical components are present; fails validation if any are missing
- **Example**:

  ```yaml
  allOf:
    - path: node-feature-discovery-operator.yaml
    - path: nvidia-gpu-operator.yaml
  ```

### 2. Custom Resource Templates

- **Naming**: Use descriptive, component-specific names (e.g., `nvidia-gpu-operator.yaml`, not `operator1.yaml`)
- **Namespace**: Explicitly specify operator namespace in templates
- **Versioning**: Include API version in all CR definitions
- **Required Fields**: Mark all operator-critical fields as required (no annotations for user variation)

### 3. Annotations Usage

- **Minimal Variation**: Foundation operators should have minimal user-configurable fields
- **Version Tolerance**: Annotate version fields only if minor version differences are acceptable
- **User-Specific Values**: Annotate only truly environment-specific values (e.g., proxy settings, registry mirrors)

### 4. Field Validation

- **Strict Matching**: Enforce strict field matching for security and performance-critical settings
- **Resource Limits**: Do not annotate resource limits as variable - enforce reference values
- **Security Contexts**: Security-related fields must match exactly

### 5. Documentation Requirements

- **Component Description**: Each operator component must include a description explaining its purpose
- **Template Description**: Individual CR templates should document what they validate
- **Failure Guidance**: Provide clear remediation guidance in descriptions

## Component Organization

### metadata.yaml Structure

```yaml
apiVersion: v2
parts:
  - name: FoundationOperators
    description: "Critical infrastructure operators required for Enterprise AI workloads"
    components:
      - name: OperatorName
        description: "Purpose and role in the AI stack"
        allOf:
          - path: operator-subscription.yaml
            description: "Validates operator subscription configuration"
          - path: operator-config.yaml
            description: "Validates operator-specific settings"
```

## Prohibited Patterns

- ❌ Using `anyOf` or `anyOneOf` for required operators
- ❌ Annotating all fields as variable
- ❌ Omitting namespace specifications
- ❌ Relying on cluster defaults for critical settings
- ❌ Using generic names or descriptions
