# GPU Infrastructure - Coding Standards and Validation Requirements

## Overview

GPU infrastructure provides hardware acceleration capabilities essential for AI/ML workloads. This section validates vendor-specific GPU operators (NVIDIA or AMD) that manage GPU drivers, device plugins, and runtime configurations.

## Validation Policy

**CONDITIONALLY REQUIRED**: At least ONE GPU vendor operator must be deployed and validated:

- **Minimum Requirement**: NVIDIA GPU Operator OR AMD GPU Operator (or both)
- **Complete Stack Validation**: Once a vendor is identified as present, ALL of its components must be validated
- **Best Practice**: Deploy only one GPU vendor stack per cluster to avoid conflicts
- **Mixed Deployments**: While technically possible to deploy both, it's not recommended unless specific use cases require heterogeneous GPU hardware

## GPU Vendor Operators

### NVIDIA GPU Operator

**Purpose**: Manages NVIDIA GPU infrastructure and drivers

**Role**: The NVIDIA GPU Operator automates the deployment and management of all components needed to utilize NVIDIA GPUs in Kubernetes/OpenShift, including:

- GPU drivers (containerized)
- NVIDIA Container Toolkit
- NVIDIA Device Plugin
- GPU Feature Discovery
- DCGM Exporter (monitoring)
- Multi-Instance GPU (MIG) support (optional)

**Supported Hardware**:

- NVIDIA Data Center GPUs: A100, H100, A30, A10, etc.
- NVIDIA Professional GPUs: RTX series, Quadro series
- Requires NVIDIA GPU with Compute Capability 6.0+ for AI/ML workloads

**Required Resources**:

- Namespace configuration
- OperatorGroup definition
- Subscription manifest

**Documentation**: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/

### AMD GPU Operator

**Purpose**: Manages AMD GPU infrastructure and drivers

**Role**: The AMD GPU Operator provides automated deployment of AMD ROCm drivers and components for AMD Instinct GPUs, including:

- AMD ROCm drivers (containerized)
- AMD Device Plugin
- Driver container management
- GPU resource discovery

**Supported Hardware**:

- AMD Instinct GPUs: MI250, MI300, MI210, MI100
- Requires AMD Instinct series for AI/ML workloads

**Required Resources**:

- Namespace configuration
- OperatorGroup definition
- Subscription manifest
- AMDGPU blacklist MachineConfig (prevents node kernel driver conflicts)
- Device Plugin configuration

**Special Configuration Notes**:

- Device Plugin configuration uses `ignore-unspecified-fields: true` to allow environment-specific GPU topology settings
- Blacklist MachineConfig prevents conflicts between containerized and node-level GPU drivers

## Coding Standards

### 1. Matching Strategy

- **Required**: Use `allOrNoneOf` matching strategy for each GPU vendor operator
- **Enforcement**: At least one GPU vendor operator MUST be present in the cluster
- **Rationale**:
  - `allOrNoneOf` ensures complete stack deployment if a vendor is chosen
  - Prevents partial GPU operator deployments that would fail at runtime
  - Allows flexibility in vendor selection based on hardware
  - Permits mixed GPU hardware in advanced scenarios

**Example**:

```yaml
components:
  - name: NVIDIA GPU Operator
    allOrNoneOf:
      - path: vendors/nvidia/gpu-operator/00_nvidia-gpu-namespace.yaml
      - path: vendors/nvidia/gpu-operator/01_nvidia-gpu-operator-operatorgroup.yaml
      - path: vendors/nvidia/gpu-operator/02_nvidia-gpu-operator-subscription.yaml

  - name: AMD GPU Operator
    allOrNoneOf:
      - path: vendors/amd/gpu-operator/00_amd-gpu-namespace.yaml
      - path: vendors/amd/gpu-operator/01_amd-gpu-opergroup.yaml
      - path: vendors/amd/gpu-operator/02_amd-gpu-subscription.yaml
      - path: vendors/amd/gpu-operator/03_amdgpu-blacklist-mc.yaml
      - path: vendors/amd/gpu-operator/04_device-plugin-config.yaml
```

### 2. Validation Logic

The validation follows this logic:

1. **Check NVIDIA Stack**: If NVIDIA GPU namespace exists → validate ALL NVIDIA components
2. **Check AMD Stack**: If AMD GPU namespace exists → validate ALL AMD components
3. **Minimum Requirement**: At least ONE complete stack must be present
4. **Failure Conditions**:
   - No GPU operator deployed → ❌ Validation fails
   - Partial NVIDIA stack (some but not all components) → ❌ Validation fails
   - Partial AMD stack (some but not all components) → ❌ Validation fails

### 3. Vendor Selection Guidance

**When to Choose NVIDIA**:

- Cluster has NVIDIA GPU hardware (A100, H100, A30, etc.)
- Workloads require CUDA libraries
- Need Multi-Instance GPU (MIG) partitioning
- Require mature ecosystem with extensive AI framework support

**When to Choose AMD**:

- Cluster has AMD Instinct GPU hardware (MI250, MI300, etc.)
- Workloads use ROCm-compatible frameworks
- Cost optimization for specific workload types
- Open-source preference for GPU compute stack

**When to Deploy Both** (Advanced):

- Heterogeneous cluster with both NVIDIA and AMD nodes
- Different workloads optimized for different vendors
- Requires careful node labeling and pod scheduling

### 4. Node Feature Discovery Integration

GPU operators depend on NFD (from Foundation Operators section) for:

- Hardware feature detection
- GPU model identification
- Node labeling for scheduling
- Topology awareness

**Validation Order**:

1. Foundation Operators (including NFD) → Must be validated first
2. GPU Infrastructure → Validated after NFD is confirmed
3. OpenShift AI Platform → Can reference GPU resources

### 5. Kernel Module Management Integration

GPU operators depend on KMM (from Foundation Operators section) for:

- Out-of-tree kernel module management
- Driver container coordination
- Kernel version compatibility
- Automated driver rebuilds on kernel updates

### 6. Configuration Flexibility

**NVIDIA Operator**:

- Minimal configuration required (operator handles most settings)
- Version pinning recommended for production stability
- Consider MIG configuration for multi-tenancy

**AMD Operator**:

- Device Plugin configuration should use `ignore-unspecified-fields: true`
- AMDGPU blacklist MachineConfig is vendor-specific and should be strictly validated
- ROCm version alignment with workload requirements

### 7. Documentation Requirements

- **Hardware Dependencies**: Document which GPU models are supported
- **Driver Versions**: Specify compatible driver versions
- **Workload Compatibility**: Note which AI frameworks work with each vendor
- **Troubleshooting**: Provide common GPU detection and scheduling issues

## Component Organization

### metadata.yaml Structure

```yaml
apiVersion: v2
parts:
  - name: GPU Infrastructure
    description: |
      GPU vendor-specific operator and configuration.
      REQUIRED: At least one GPU vendor operator must be deployed.
      Best practice: Deploy only one GPU vendor stack unless heterogeneous hardware requires both.

    components:
      - name: NVIDIA GPU Operator
        description: |
          NVIDIA GPU Operator for NVIDIA GPUs (A100, H100, etc.).
          Includes driver installation, device plugin, and optional MIG support.
        allOrNoneOf:
          - path: vendors/nvidia/gpu-operator/00_nvidia-gpu-namespace.yaml
          - path: vendors/nvidia/gpu-operator/01_nvidia-gpu-operator-operatorgroup.yaml
          - path: vendors/nvidia/gpu-operator/02_nvidia-gpu-operator-subscription.yaml

      - name: AMD GPU Operator
        description: |
          AMD GPU Operator for AMD Instinct GPUs (MI250, MI300, etc.).
          Includes ROCm drivers and device plugin.
        allOrNoneOf:
          - path: vendors/amd/gpu-operator/00_amd-gpu-namespace.yaml
          - path: vendors/amd/gpu-operator/01_amd-gpu-opergroup.yaml
          - path: vendors/amd/gpu-operator/02_amd-gpu-subscription.yaml
          - path: vendors/amd/gpu-operator/03_amdgpu-blacklist-mc.yaml
          - path: vendors/amd/gpu-operator/04_device-plugin-config.yaml
            config:
              ignore-unspecified-fields: true
```
