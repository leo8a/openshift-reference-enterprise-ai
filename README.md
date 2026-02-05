# OpenShift Validated Reference Design for Enterprise AI

## Overview

This reference configuration uses the kube-compare tool to validate a complete Red Hat OpenShift 4.20+ deployment, including AI/ML platform infrastructure such as:

- **Foundation operators**: Node Feature Discovery (NFD) and Kernel Module Management (KMM)

The reference uses kube-compare V2 format with logical operators (`allOf`, `oneOf`, `anyOf`) to enforce architectural requirements while allowing configuration flexibility.
