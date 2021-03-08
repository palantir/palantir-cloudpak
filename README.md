<p align="right">
<a href="https://autorelease.general.dmz.palantir.tech/palantir/palantir-cloudpak"><img src="https://img.shields.io/badge/Perform%20an-Autorelease-success.svg" alt="Autorelease"></a>
</p>

# palantir-cpd-module

This repository provides a CPD Assembly module and a CASE for the palantir-operator to install and run Palantir for IBM Cloud Pak For Data (P4CP4D) on along side Cloud Pak For Data (CP4D) 3.5+ in an Open Shift Compute Platform (OSCP) 4.5+.

## Supported Platforms, Architectures and Cloud Providers

Palantir for IBM Cloudpak for Data supports the following:

_Platforms_

- Open Shift Compute Platform versions: 4.5+
- Cloudpak for Data: 3.5

_Architectures_

- x86_64

_Cloud Providers_

P4CP4D can be run on any cloud provider so long as the following are true:

- An OpenShift storage class is available that supports 3,000 IPS with READ and WRITE average latency of less than 1ms and p95 latency of less than 5ms.
- A blob storage service that offers an AWS S3 compatible API.

## Pre-requisites

Before installation can happen, the IP addresses that network traffic will egress the OSCP cluster from must be added to a security group for communicating with Palantir's delivery environment and container registry. This must be done by Palantir support prior to installation via the Palantir operator.

Palantir will then provide the following:

- A Palantir registration key that is used to authenticate and authorize your Palantir for Cloudpak for Data installation against Palantir's delivery environment.
- A username and password to authenticate with the Palantir container registry.

Finally, in addition to the Palantir provided information, you must have the following information prior to installing Palantir for Cloudpak for Data:

- An IBM entitlement key that is entitled to Palantir for IBM Cloudpak for Data.

## How to install Palantir for IBM Cloudpak for Data

The following instructions assume you have either checked out this git repository or have downloaded a release TGZ of the CPD Assembly module. Follow these steps to install Palantir for Cloud Pak for Data against an OpenShift Compute Platform that already has CP4D installed.

1. Switch to the `cpd` folder from either the git repository or the decompressed CPD Assembly module TGZ.
2. Run `install-prereq.sh` to download the necessary CLI that knows how to manage the Assembly.
3. Copy `cpd/modules/palantir-operator/x86_64/1.0.0/install-overrides.yaml` to `cpd/override.yaml`. The Assembly module will use the `cpd/override.yaml` file. Fill in the override values based on the OSCP and Cloudpak instance you want to install Palantir in.
4. Pick the namespace that you want to install the palantir-operator in. Note that this should be different than the namespace in which CP4D has been installed. Set an environment variable `NAMESPACE` with the namespace you picked. Example: `export NAMESPACE=palantir`
5. Set an environment variable `CPD_NAMESPACE` for the namespace where CP4D is installed. Example: `export CPD_NAMESPACE=cp4d`
6. Set an environment variable `STORAGE_CLASS` for the Kubernetes storage class you specified in the `override.yaml` from Step 3. Example: `export STORAGE_CLASS=ibmc-file-gold-gid`
7. Set environment variables `DOCKER_USERNAME` and `DOCKER_PASSWORD` for your login to Palantir's container registry. These environment variables will get used by the script in the next step.
8. Run `run.sh install` to install the palantir-operator into this namespace.
9. If the installation fails and you want to retry it again, you will need to run `run.sh uninstall` first before trying again.

## Operator scoping and use of namespaces

The Palantir operator to install P4CP4D results in the following OpenShift namespaces being created:

- `$NAMESPACE` - the environment variable defined as part of the installation steps above is the name of the namespace used to run the Palantir Operator deployment.
- `palantir-cloudpak-compute-misc` - namespace which contains non-Spark Palantir compute services.
- `palantir-cloudpak-compute-spark` - namespace which contains Spark specific Palantir compute services.
- `palantir-cloudpak-data` - namespace which contains persisted data storage services (Cassandra, Elastic Search, etc).
- `palantir-cloudpak-infrastructure` - namespace which contains infrastructure and control plane services responsible for managing the services that make up the Palantir platform.
- `palantir-cloudpak-services` - namespace which contains the core Palantir services for P4CP4D.
