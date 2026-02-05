# Storage Backends - Coding Standards and Validation Requirements

## Overview

Storage backends provide persistent storage capabilities required for AI/ML workloads, including model storage, dataset storage, and pipeline artifacts. Unlike foundation operators and platform components that are always mandatory, storage backends may vary based on infrastructure and deployment requirements.

## Validation Policy

**CONDITIONAL MANDATORY**: Storage backend components use the `allOrNoneOf` matching strategy. This means:

- Either ALL specified storage components must be present in the cluster
- OR NONE of them should be present
- Mixed presence (some but not all) triggers validation failure

This approach ensures consistency in storage configuration while allowing flexibility for different infrastructure choices.

## Storage Backend Components

### Logical Volume Manager Storage (LVMS)

**Purpose**: Local storage management using LVM

**Role**: LVMS is the recommended storage backend for OpenShift AI deployments, especially for edge and single-node OpenShift environments. It provides dynamic provisioning of local persistent volumes, which is critical for:

- Jupyter notebook workspaces
- Data science pipeline artifacts
- Model storage and versioning
- Training dataset caching

**Importance for OpenShift AI**:

- **Performance**: Local storage provides low-latency access for data-intensive AI/ML workloads
- **Simplicity**: Eliminates external storage dependencies for development and testing environments
- **Resource Efficiency**: Utilizes local disk resources efficiently
- **Integration**: Seamlessly integrates with OpenShift AI's storage requirements

**Required Resources**:

- Namespace configuration
- OperatorGroup definition
- Subscription manifest
- LVMCluster custom resource (storage pool configuration)

**Infrastructure Requirements**:

- Available local disks or block devices on cluster nodes
- Sufficient disk space for workload requirements (typically 100GB+ per node)

## Coding Standards

### 1. Matching Strategy

- **Required**: Use `allOrNoneOf` matching strategy for storage backends
- **Rationale**: Ensures complete storage stack deployment or allows alternative storage solutions; prevents incomplete configurations
- **Example**:

  ```yaml
  allOrNoneOf:
    - path: common/storage/lvms/00_lvms-namespace.yaml
    - path: common/storage/lvms/01_lvms-operatorgroup.yaml
    - path: common/storage/lvms/02_lvms-subscription.yaml
    - path: common/storage/lvms/03_lvmcluster-cr.yaml
  ```

### 2. When to Use allOrNoneOf

This strategy is appropriate for storage backends because:

- **Alternative Solutions Exist**: Organizations may use ODF, NFS, cloud storage, or other solutions instead
- **Complete Stack Required**: If LVMS is chosen, all components must be present for it to function
- **Consistency Check**: Prevents partial deployments that would fail at runtime
- **Flexibility**: Allows validation to pass with alternative storage as long as OpenShift AI has persistent storage available

### 3. Storage Class Validation

- **Default Storage Class**: Validate that an appropriate default StorageClass exists
- **Access Modes**: Ensure storage supports required access modes (ReadWriteOnce, ReadWriteMany)
- **Volume Binding**: Consider validating volume binding mode (WaitForFirstConsumer vs Immediate)
- **Reclaim Policy**: Validate appropriate reclaim policies for AI/ML data

### 4. LVMCluster Configuration

- **Device Selector**: Validate device selection strategy (by path, by name, or all available)
- **Thin Provisioning**: Consider whether thin provisioning is enabled
- **Storage Class Name**: Ensure consistent naming for integration with OpenShift AI
- **Node Selector**: Validate which nodes provide storage capacity

### 5. Capacity Planning

- **Minimum Size**: Define minimum disk requirements for AI/ML workloads
- **Growth Projection**: Consider validating that storage can accommodate workload growth
- **Multi-tenancy**: Ensure sufficient capacity for multiple data science projects
- **Ephemeral vs Persistent**: Distinguish between ephemeral workspace storage and persistent model/data storage

### 6. Documentation Requirements

- **Alternative Options**: Document what other storage solutions can be used
- **Capacity Requirements**: Specify minimum and recommended storage capacity
- **Performance Characteristics**: Explain performance implications of storage choices
- **Integration Points**: Document how storage integrates with OpenShift AI components

## Component Organization

### metadata.yaml Structure

```yaml
apiVersion: v2
parts:
  - name: Storage Backends
    description: "Persistent storage solutions for AI/ML workloads"
    components:
      - name: LVM Storage
        description: "Local volume manager for persistent storage"
        allOrNoneOf:
          - path: common/storage/lvms/00_lvms-namespace.yaml
            description: "LVMS operator namespace configuration"
          - path: common/storage/lvms/01_lvms-operatorgroup.yaml
            description: "LVMS operator group definition"
          - path: common/storage/lvms/02_lvms-subscription.yaml
            description: "LVMS operator subscription"
          - path: common/storage/lvms/03_lvmcluster-cr.yaml
            description: "LVM cluster storage pool configuration"
```
