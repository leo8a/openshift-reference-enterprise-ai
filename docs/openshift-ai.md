# OpenShift AI Platform - Coding Standards and Validation Requirements

## Overview

The OpenShift AI Platform section defines the complete Red Hat OpenShift AI deployment, including the platform operator and all required serving infrastructure dependencies. This represents the core AI/ML platform layer that enables data science workloads, model training, and model serving capabilities.

## Validation Policy

**MANDATORY**: All OpenShift AI Platform components defined in this reference MUST be validated in every target cluster. These are not optional - they form the complete, production-ready OpenShift AI platform. Their absence indicates an incomplete or non-compliant deployment.

## Required OpenShift AI Platform Components

This reference design requires the following components for a complete OpenShift AI platform deployment:

### OpenShift AI Operator

**Purpose**: Red Hat OpenShift AI operator and platform configuration

**Role**: The core platform operator that provides the complete AI/ML workbench experience, including Jupyter notebooks, data science pipelines, model serving, and distributed workload management. It orchestrates all OpenShift AI components through the DataScienceCluster custom resource.

**Required Resources**:

- Namespace configuration
- OperatorGroup definition
- Subscription manifest
- DataScienceCluster custom resource (platform configuration)
- Group configuration for admin access (with flexible field matching)
- HardwareProfile custom resource (for GPU acceleration support)

**Special Configuration Notes**:

- The Group configuration uses `ignore-unspecified-fields: true` to allow flexibility in group membership while enforcing core RBAC structure
- HardwareProfile/AcceleratorProfile enables GPU-accelerated workloads and must align with the GPU operators deployed

### Service Mesh 2

**Purpose**: Red Hat OpenShift Service Mesh operator (Istio-based)

**Role**: Provides advanced traffic management, observability, and security for microservices. This is a **mandatory dependency** for OpenShift AI model serving features, enabling the inference gateway functionality that routes requests to deployed models.

**Required Resources**:

- Subscription manifest

**Dependency Chain**: Service Mesh must be deployed before enabling model serving features in the DataScienceCluster.

### Serverless

**Purpose**: Red Hat OpenShift Serverless operator (Knative-based)

**Role**: Enables serverless application deployment and auto-scaling capabilities. This is a **mandatory dependency** for OpenShift AI KServe model serving, providing the underlying infrastructure for serving models with automatic scaling based on demand.

**Required Resources**:

- Namespace configuration
- OperatorGroup definition
- Subscription manifest

**Dependency Chain**: Serverless must be deployed before enabling KServe model serving in the DataScienceCluster.

### Authorino

**Purpose**: Red Hat Authorino operator for API authentication and authorization

**Role**: Provides policy-based API security and token validation. This is a **mandatory dependency** for OpenShift AI model serving security, enabling token-based authentication for inference endpoints and protecting deployed models.

**Required Resources**:

- Subscription manifest

**Dependency Chain**: Authorino must be deployed before enabling secure model serving features.

### Component Dependencies

The OpenShift AI Platform has a clear dependency structure:

```yaml
Foundation Operators (NFD + KMM)
    ↓
OpenShift AI Operator + Service Mesh + Serverless + Authorino
    ↓
Model Serving Capabilities Enabled
```

All four components (OpenShift AI Operator, Service Mesh, Serverless, and Authorino) should be deployed together as they are tightly coupled for model serving functionality.

## Coding Standards

### 1. Matching Strategy

- **Required**: Use `allOf` matching strategy for all OpenShift AI Platform components
- **Rationale**: The platform requires all components to function correctly; missing any component results in a non-functional or incomplete platform
- **Example**:

  ```yaml
  allOf:
    - path: common/platform/openshift-ai/02_ocpai-sub.yaml
    - path: common/platform/openshift-ai/03_DataScienceCluster-cr.yaml
  ```

### 2. DataScienceCluster Configuration

- **Critical Resource**: The DataScienceCluster CR is the most important configuration in this section
- **Component Enablement**: Validate that required components (dashboard, workbenches, model serving) are enabled
- **Serving Stack**: Ensure KServe and/or ModelMesh serving platforms are configured according to requirements
- **Resource Specifications**: Define resource limits and requests for platform components

### 3. Configuration Flexibility

- **Group Management**: Use `ignore-unspecified-fields: true` for Group configurations to allow organization-specific membership
- **User-Specific Values**: Annotate environment-specific values like:
  - Storage class names
  - Domain names for routes
  - Certificate references
  - Image registry mirrors
- **Platform Defaults**: Do not annotate core platform settings as variable

### 4. Hardware Acceleration

- **HardwareProfile/AcceleratorProfile**: Must reference GPU types that align with deployed GPU operators
- **Node Selectors**: Validate that GPU node selectors and tolerations are properly configured
- **Resource Requests**: Ensure GPU resource requests match available hardware

### 5. Serving Dependencies Validation

- **Service Mesh**: Validate subscription channel and version compatibility
- **Serverless**: Ensure Knative Serving is properly configured
- **Authorino**: Verify operator deployment before model serving enablement
- **Integration**: All three serving dependencies must be present before DataScienceCluster enables serving features

### 6. Documentation Requirements

- **Component Purpose**: Clearly document why each component is required
- **Dependency Relationships**: Explain how components interact
- **Configuration Impact**: Document what happens when specific settings are changed
- **Troubleshooting**: Provide guidance for common validation failures

## Component Organization

### metadata.yaml Structure

```yaml
apiVersion: v2
parts:
  - name: OpenShift AI Platform
    description: "Red Hat OpenShift AI platform operators and core components"
    components:
      - name: OpenShift AI Operator
        description: "Core platform operator and configuration"
        allOf:
          - path: common/platform/openshift-ai/03_DataScienceCluster-cr.yaml
            description: "Validates platform component enablement and configuration"
          - path: common/platform/openshift-ai/04_Group-config.yaml
            description: "Validates admin RBAC structure"
            config:
              ignore-unspecified-fields: true

      - name: Service Mesh 2
        description: "Service mesh for model serving infrastructure"
        allOf:
          - path: common/platform/service-mesh/00_service-mesh2-subscription.yaml
```

## Best Practices

1. **Deploy as a Unit**: All OpenShift AI Platform components should be deployed together
2. **Validate Dependencies**: Ensure foundation operators are validated before platform components
3. **Version Alignment**: Maintain compatible versions across Service Mesh, Serverless, and Authorino
4. **Resource Planning**: Define appropriate resource limits for platform components
5. **Security First**: Validate that authentication and authorization are properly configured
6. **GPU Integration**: Ensure HardwareProfile aligns with actual GPU hardware and drivers

## Prohibited Patterns

- ❌ Using `anyOf` or `oneOf` for required platform components
- ❌ Making Service Mesh, Serverless, or Authorino optional
- ❌ Omitting DataScienceCluster configuration validation
- ❌ Skipping HardwareProfile when GPU support is required
- ❌ Deploying platform components without foundation operator validation
- ❌ Using generic descriptions that don't explain component purpose
