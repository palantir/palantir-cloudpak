<p align=right>
<a href=https://autorelease.bots.palantir.build/deployability/foundry-cpd-module><img src=https://shields.palantir.build/badge/Perform%20an-Autorelease-brightgreen.svg alt=Autorelease></a>
</p>

# palantir-cpd-module

This repository provides a CASE for the palantir-operator to install and run Palantir for Cloud Pak For Data (P4CP4D) on along side Cloud Pak For Data (CP4D) 3.5+ in an Open Shift Compute Platform (OSCP) 4.5+.

## Pre-requisites

Prior to installing Palantir for Cloudpak for Data, you must have the following information:

- An IBM entitlement key that is entitled to Palantir for Cloudpak for Data
- A Palantir registration key that is used to authenticate and authorize your Palantir for Cloudpak for Data installation against Palantir's delivery environment. This should be provided by the IBM sales team.
- A username and password to authenticate with the Palantir container registry. This should be provided by the IBM sales team.

In addition, the IP addresses that network traffic will egress the OSCP cluster from must be added to a security group for communicating with Palantir's delivery environment and container registry. This must be done by Palantir support prior to installation via the Palantir operator.

## How to run it

The following instructions assume you have either checked out this git repository or have downloaded a release TGZ of the CASE module. Follow these steps to install Palantir for Cloud Pak for Data against an OpenShift Compute Platform that already has CP4D installed.

1. Switch to the `case` folder from either the git repository or the decompressed CASE module TGZ.
2. Run `install-prereq.sh` to download the necessary CLI that knows how to manage CASE.
3. Copy `case/modules/palantir-operator/x86_64/1.0.0/install-overrides.yaml` to `case/override.yaml`. The CASE module will use the `case/override.yaml` file. Fill in the override values based on the OSCP and Cloudpak instance you want to install Palantir in.
4. Pick the namespace that you want to install the palantir-operator in. Note that this should be different than the namespace in which CP4D has been installed. Set an environment variable `NAMESPACE` with the namespace you picked. Example: `export NAMESPACE=palantir`
5. Set an environment variable `CPD_NAMESPACE` for the namespace where CP4D is installed. Example: `export CPD_NAMESPACE=cp4d`
6. Set an environment variable `STORAGE_CLASS` for the Kubernetes storage class you specified in the `override.yaml` from Step 3. Example: `export STORAGE_CLASS=ibmc-file-gold-gid`
7. Get the docker username and password to authenticate with Palantir's container registry. Export these values as DOCKER_USERNAME and DOCKER_PASSWORD environment variables to these values. These environment variables will get used by the script in the next step.
8. Run `run.sh install` to install the palantir-operator into this namespace.
9. If the installation fails and you want to retry it again, you will need to run `run.sh uninstall` first before trying again.
