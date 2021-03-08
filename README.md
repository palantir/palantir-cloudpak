<p align="right">
<a href="https://autorelease.general.dmz.palantir.tech/palantir/palantir-cloudpak"><img src="https://img.shields.io/badge/Perform%20an-Autorelease-success.svg" alt="Autorelease"></a>
</p>

# palantir-cloudpak

This repository provides a CPD Assembly module and a CASE for the palantir-operator to install and run Palantir for Cloud Pak For Data (P4CP4D) on along side Cloud Pak For Data (CP4D) 3.5+ in an Open Shift Compute Platform (OSCP) 4.5+.

## Pre-requisites

Before installation can happen, the IP addresses that network traffic will egress the OSCP cluster from must be added to a security group for communicating with Palantir's delivery environment and container registry. This must be done by Palantir support prior to installation via the Palantir operator.

Palantir will then provide the following:

- A Palantir registration key that is used to authenticate and authorize your Palantir for Cloudpak for Data installation against Palantir's delivery environment.
- A username and password to authenticate with the Palantir container registry.

Finally, in addition to the Palantir provided information, you must have the following information prior to installing Palantir for Cloudpak for Data:

- An IBM entitlement key that is entitled to Palantir for Cloudpak for Data.

## How to run it

The following instructions assume you have either checked out this git repository or have downloaded a release TGZ of the CPD Assembly module. Follow these steps to install Palantir for Cloud Pak for Data against an OpenShift Compute Platform that already has CP4D installed.

1. Switch to the `cpd` folder from either the git repository or the decompressed CPD Assembly module TGZ.
2. Run `install-prereq.sh` to download the necessary CLI that knows how to manage the Assembly.
3. Copy `cpd/modules/palantir-operator/x86_64/1.0.0/install-overrides.yaml` to `cpd/override.yaml`. The Assembly module will use the `cpd/override.yaml` file. Fill in the override values based on the OSCP and Cloudpak instance you want to install Palantir in.
4. Pick the namespace that you want to install the palantir-operator in. Note that this should be different than the namespace in which CP4D has been installed. Set an environment variable `NAMESPACE` with the namespace you picked. Example: `export NAMESPACE=palantir`
5. Set an environment variable `CPD_NAMESPACE` for the namespace where CP4D is installed. Example: `export CPD_NAMESPACE=cp4d`
6. Set an environment variable `STORAGE_CLASS` for the Kubernetes storage class you specified in the `override.yaml` from Step 3. Example: `export STORAGE_CLASS=ibmc-file-gold-gid`
7. Get the docker username and password to authenticate with Palantir's container registry. Export these values as DOCKER_USERNAME and DOCKER_PASSWORD environment variables to these values. These environment variables will get used by the script in the next step.
8. Run `run.sh install` to install the palantir-operator into this namespace.
9. If the installation fails and you want to retry it again, you will need to run `run.sh uninstall` first before trying again.
