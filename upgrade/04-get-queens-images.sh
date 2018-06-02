#!/bin/bash

set -euxo pipefail
cd $HOME

RELEASE=queens
THT="/usr/share/openstack-tripleo-heat-templates"

openstack overcloud container image prepare \
  --namespace tripleo${RELEASE} \
  --tag current-tripleo \
  --push-destination 192.168.24.1:8787/tripleo${RELEASE} \
  --output-images-file ~/${RELEASE}-container-images.yaml \
  -e $THT/environments/docker.yaml \
  -e $THT/environments/docker-ha.yaml \
  -e basic-deployment.yaml \

openstack overcloud container image upload \
  --debug \
  --config-file ~/${RELEASE}-container-images.yaml \

openstack overcloud container image prepare \
  --namespace 192.168.24.1:8787/tripleo${RELEASE} \
  --tag current-tripleo \
  --output-env-file ~/${RELEASE}-container-params.yaml \
  -e $THT/environments/docker.yaml \
  -e $THT/environments/docker-ha.yaml \
  -e basic-deployment.yaml \
