# File Naming Standards

## Naming Pattern

All resource files follow the pattern: `NN_component-name.yaml`

- **NN**: Two-digit prefix (00-99) indicating deployment order
- **component-name**: kebab-case descriptor
- **Extension**: Always `.yaml`

## Deployment Order

Files must be numbered according to deployment dependencies:

| Prefix | Resource Type | Example |
| ------ | ------------- | ------- |
| `00_`  | Namespace | `00_nfd-namespace.yaml` |
| `01_`  | OperatorGroup | `01_nfd-operatorgroup.yaml` |
| `02_`  | Subscription | `02_nfd-subscription.yaml` |
| `03_+` | Custom Resources | `03_nodeFeatureDiscovery-cr.yaml` |

**Rule**: Lower numbers deploy first.

## Naming Rules

### Standard Resources (00-02)

Format: `NN_prefix-resourcetype.yaml`

- Use component abbreviation as prefix (e.g., `nfd`, `kmm`, `lvms`, `nvidia-gpu`, `amd-gpu`)
- Resource type must be one of: `namespace`, `operatorgroup`, `subscription`

**Examples**:

```yaml
00_nfd-namespace.yaml
01_nfd-operatorgroup.yaml
02_nfd-subscription.yaml
```

### Custom Resources (03+)

Format: `NN_resourceName-cr.yaml`

- Use the actual Kubernetes resource name
- **Start with lowercase letter**
- Preserve camelCase from the resource Kind
- Append `-cr` suffix

**Examples**:

```yaml
03_nodeFeatureDiscovery-cr.yaml    # NodeFeatureDiscovery resource
03_lvmCluster-cr.yaml               # LVMCluster resource
04_storageClass-cr.yaml             # StorageClass resource
```

## Complete Examples

### Node Feature Discovery

```yaml
00_nfd-namespace.yaml
01_nfd-operatorgroup.yaml
02_nfd-subscription.yaml
03_nodeFeatureDiscovery-cr.yaml
```

### LVMS Operator

```yaml
00_lvms-namespace.yaml
01_lvms-operatorgroup.yaml
02_lvms-subscription.yaml
03_lvmCluster-cr.yaml
04_storageClass-cr.yaml
```

### AMD GPU Operator

```yaml
00_amd-gpu-namespace.yaml
01_amd-gpu-operatorgroup.yaml
02_amd-gpu-subscription.yaml
03_amdgpu-blacklist-mc.yaml
04_device-plugin-config.yaml
```

## Directory Structure

```text
common/
├── foundation/
│   ├── nfd-operator/
│   └── kmm-operator/
├── storage/
│   └── lvms-operator/
└── platform/
    ├── openshift-ai/
    ├── service-mesh/
    ├── serverless/
    └── authorino/

vendors/
├── nvidia/gpu-operator/
└── amd/gpu-operator/
```

**Categories**:

- `common/foundation/` - Foundation operators (NFD, KMM)
- `common/storage/` - Storage backends (LVMS)
- `common/platform/` - Platform components (OpenShift AI, Service Mesh, Serverless, Authorino)
- `vendors/` - Vendor-specific components (NVIDIA, AMD GPU operators)

## Component Abbreviations

| Component | Abbreviation |
| --------- | ------------ |
| Node Feature Discovery | `nfd` |
| Kernel Module Management | `kmm` |
| Logical Volume Manager Storage | `lvms` |
| OpenShift AI | `ocpai` |
| GPU (NVIDIA) | `nvidia-gpu` |
| GPU (AMD) | `amd-gpu` |

## Validation Checklist

- [ ] Two-digit numeric prefix (00-99)
- [ ] Deployment order: namespace(00), operatorgroup(01), subscription(02), CRs(03+)
- [ ] Standard resources use component prefix
- [ ] Custom resources use actual resource name starting with lowercase
- [ ] All filenames use kebab-case
- [ ] Paths in `metadata.yaml` listed in numeric order

## Common Mistakes

❌ **Wrong**:

```yaml
nfd-namespace.yaml                  # Missing numeric prefix
1_nfd-namespace.yaml                # Single digit
00_NFD-namespace.yaml               # Uppercase
03_nfd-nodeFeatureDiscovery-cr.yaml # Component prefix on CR (should start with resource name)
```

✅ **Correct**:

```yaml
00_nfd-namespace.yaml
01_nfd-operatorgroup.yaml
02_nfd-subscription.yaml
03_nodeFeatureDiscovery-cr.yaml
```
