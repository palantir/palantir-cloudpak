<p align="right">
<a href="https://autorelease.general.dmz.palantir.tech/palantir/palantir-cloudpak"><img src="https://img.shields.io/badge/Perform%20an-Autorelease-success.svg" alt="Autorelease"></a>
</p>

# palantir-cloudpak

This repository provides a CPD Assembly module for the palantir-operator to install and run Palantir for IBM Cloud Pak For Data (P4CP4D) on along side Cloud Pak For Data 3.5+ in an Open Shift Container Platform (OCP) 4.5+.

## Planning

You can install Palantir for IBM Cloud Pak for Data on top of Cloud Pak for Data.

### Supported Platforms, Architectures and Cloud Providers

To install Palantir for IBM Cloud Pak for Data, you must have the following software already installed on your cluster:

- Red hat OpenShift Container Platform version 4.5 or later.
- IBM Cloud Pak for Data 3.5 or later refreshes. For more information, see:
  - [Planning for Cloud Pak for Data](https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.5.0/cpd/plan/planning.html)
  - [Installing Cloud Pak for Data](https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.5.0/cpd/install/install.html)
- IBM Watson Knowledge Catalog version 3.5.x.

_Architectures_

Palantir for IBM Cloud Pak for Data must be run on compute nodes that support the x86_64 architecture.

_Cloud Providers_

Palantir for IBM Cloud Pak for Data can be run on any cloud provider so long as the following are true:

- An OpenShift storage class is available that supports:
  - 3,000 IOPS with a sustained throughput of 256MiB/s
  - READ and WRITE average latency of less than 1ms and p95 latency of less than 5ms.
- A blob storage service that offers an AWS S3 compatible API.

### Security Considerations

Palantir for IBM Cloud Pak for Data supports encryption at rest and in transit.

*Encryption in transit*:

- Communication between services occurs over TLS 1.2 using strong, industry-standard ciphersuites.

*Encryption at rest*:

- All Foundry Filesystems (blob storage) are secured with application level encryption. See below for details.
- Encryption of metadata and other local storage should be provided passively via encrypted storage partitions exposed via configured storage classes in OpenShift.

*Palantir Foundry Filesystem Encryption*:

- Each file encrypted with distinct symmetric key (AES-256)
- AES keys are envelope encrypted with an asymmetric keypair (RSA-2048) known only to the Palantir Foundry Catalog

### Licenses

Additionally, to install the software, you must have the following entitlement keys:

- An IBM entitlement key that includes entitlements for Cloud Pak for Data and Palantir for Cloud Pak for Data. For details on how to get your entitlement key, see [Obtaining the installation files](https://www.ibm.com/support/knowledgecenter/SSQNUZ_3.5.0/cpd/install/installation-files.html) in the IBM Cloud Pak for Data documentation.  
- A Palantir registration key. For details on how to get your registration key, see [Obtaining your registration key](#obtaining-your-registration-key)
​

### Obtaining your registration key

Before you can install Palantir, you must provide information about your cluster to Palantir.
​
Send the following information to Palantir:

- The IP addresses that are used for outbound network traffic from your OpenShift Container Platform cluster.
​
Palantir will add these IP addresses to a security group so that your cluster can connect to the Palantir delivery environment and container registry.

After this task is complete, Palantir will send you:

- Your Palantir registration key, which gives you access to the delivery environment
- Your username and password, which you use to authenticate to the Palantir container registry.

## Installing Palantir for IBM Cloud Pak for Data

Installing Palantir for IBM Cloud Pak for Data uses the IBM Cloud Pak for Data installer (`cpd-cli`) to install a Cloud Pak for Data Assembly, which can be found at https://github.com/palantir/palantir-cloudpak. The cpd-cli and Palantir assembly are responsible for preparing the OCP cluster resources and deploying the Palantir operator. The Palantir operator is then responsible for installing the P4CP4D platform. The Palantir Operator and P4CP4D container images are provided by the Palantir container registry. Instructions below are provided for information necessary to authenticate with the Palantir container registry and how to configure the installer to communicate with it.

### Pre-requisites

The installation instructions below assume the following:

- IBM Cloud Pak for Data Installer v3.5.x has already been downloaded and is available. Details can be found at https://github.com/IBM/cpd-cli.
- The Palantir for IBM Cloud Pak for Data Assembly has been downloaded. Details can be found at https://github.com/palantir/palantir-cloudpak.
- All pre-requisite software outlined in [Supported Platforms, Architectures and Cloud Providers](#supported-platforms,-architectures-and-cloud-providers) must already be installed.

### How to install Palantir for IBM Cloud Pak for Data

#### Define installation settings

You will need the following pieces of information for the installation process:

- `$NAMESPACE` - Pick the namespace that you want to install the palantir-operator in. Note that this should be different than the namespace in which Cloud Pak for Data has been installed.
- `$CPD_NAMESPACE` - the existing OpenShift namespace that the IBM Cloud Pak for Data installation exists within.
- `$STORAGE_CLASS` - the Kubernetes storage class to use for storing data in P4CP4D.
- `$PALANTIR_DOCKER_USER` - the username to authenticate to Palantir's container registry
- `$PALANTIR_DOCKER_PASSWORD` - the password to authenticate to Palantir's container registry

These will be referenced in the installation steps below. It is easiest to export these values as environment variables so it can referenced in the `cpd-cli` steps.

Take the following steps to configure the installation:

1. Starting in the directory which you extract the Palantir for IBM Cloud Pak for Data Assembly module, switch to the `cpd` folder.
2. Copy `./modules/palantir-operator/x86_64/1.0.0/install-overrides.yaml` to `./override.yaml`. The Assembly module will use the `cpd/override.yaml` file. Fill in the override values based on the OCP and Cloud Pak for Data instance you want to install Palantir in.
3. Copy `./cpd-cli/repo.yaml` to `./repo.yaml`. The `cpd-cli` will reference this file for gaining acess to the necessary Palantir operator images. Fill in the `TODO:` values with the referenced variables above.

#### Installation Steps

There are two steps to installing Palantir for IBM Cloud Pak for Data.

```bash
./cpd-cli/cpd-cli adm \
        --repo ./repo.yaml \
        --assembly palantir-cloudpak \
        --download-path ./cpd-cli-workspace \
        --namespace $CPD_NAMESPACE \
        --tether-to $NAMESPACE \
        --apply \
        --verbose

  ./cpd-cli/cpd-cli install \
        --repo ./repo.yaml \
        --assembly palantir-cloudpak \
        --download-path ./cpd-cli-workspace \
        --override ./override.yaml \
        --namespace $CPD_NAMESPACE \
        --tether-to $NAMESPACE \
        --instance $NAMESPACE \
        --storageclass $STORAGE_CLASS \
        --verbose

```

#### Uninstalling

If the installation fails and you want to retry it again, run the following commands before trying again:

```bash
./cpd-cli/cpd-cli uninstall \
        --assembly palantir-cloudpak \
        --namespace $CPD_NAMESPACE \
        --instance $NAMESPACE \
        --verbose

oc delete namespace $NAMESPACE
```

### Operator scoping and use of namespaces

The Palantir operator to install P4CP4D results in the following OpenShift namespaces being created:

- `$NAMESPACE` - the environment variable defined as part of the installation steps above is the name of the namespace used to run the Palantir Operator deployment.
- `palantir-cloudpak-compute-misc` - namespace which contains non-Spark Palantir compute services.
- `palantir-cloudpak-compute-spark` - namespace which contains Spark specific Palantir compute services.
- `palantir-cloudpak-data` - namespace which contains persisted data storage services (Cassandra, Elastic Search, etc).
- `palantir-cloudpak-infrastructure` - namespace which contains infrastructure and control plane services responsible for managing the services that make up the Palantir platform.
- `palantir-cloudpak-services` - namespace which contains the core Palantir services for P4CP4D.
