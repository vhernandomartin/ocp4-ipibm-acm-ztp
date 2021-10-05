# ocp4-ipibm-acm-ztp
## Description

**Disclaimer: This procedure is not officially supported, it has been written just for testing purposes.**

This repository contains a set of scripts to deploy a new spoke using ZTP Workflow (Zero Touch Provisioning), this workflow is based on RHACM (Red Hat Advanced Cluster Management) being the engine that manages and deploy spokes. RHACM is already deployed in a OpenShift 4 IPI BareMetal cluster.

For additional info on what is ZTP and how it can be deployed, check the documentation: https://github.com/jparrill/ztp-the-hard-way

## Requirements
* OpenShift 4 IPI BareMetal cluster already deployed. You can easily deploy a cluster following these steps: https://github.com/vhernandomartin/ocp4-ipibm-scripts
* Check and adjust the scripts based on your preferences, you will find many network parameters, name & network servers that might not fit your requirements, so feel free to change any parameter value you consider.

## Procedure details
* Inspect the scripts before run the procedure, adjust the variables to your requirements (Network ranges, IPs, server names, etc).
* Some of the steps needs from a SSH keys, pull secrets or a valid cert from your internal registry, check the bundle of scripts and set it up accordingly.
* The scripts are ordered by number, follow the sequence. Some of the steps have two choices, run the step based on your spoke deployment, SNO (Single Node OpenShift) or OCP3M (OpenShift 3 Masters).
