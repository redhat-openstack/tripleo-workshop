#!/bin/bash

source /home/stack/stackrc

openstack overcloud container image prepare \
    --namespace 10.12.50.1/triplequeens \
    --tag current-tripleo \
    --output-env-file /home/stack/environments/docker_registry.yaml \
    --output-images-file /home/stack/templates/overcloud_containers.yaml
