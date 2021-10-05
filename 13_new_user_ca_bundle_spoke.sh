#!/bin/bash

oc delete cm user-ca-bundle -n openshift-config
oc create -f user-ca-bundle.yaml
