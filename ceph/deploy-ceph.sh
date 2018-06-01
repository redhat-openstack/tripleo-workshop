#!/usr/bin/env bash

source ~/stackrc

time openstack overcloud deploy \
    --templates /usr/share/openstack-tripleo-heat-templates/ \
    --libvirt-type qemu \
    --compute-flavor oooq_compute --ceph-storage-flavor oooq_ceph \
    --timeout 90 \
    -e /home/stack/cloud-names.yaml      \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml   \
    -e /usr/share/openstack-tripleo-heat-templates/environments/docker-ha.yaml  \
    -e /home/stack/containers-default-parameters.yaml  \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/net-single-nic-with-vlans.yaml \
    -e /home/stack/network-environment.yaml  \
    -e /usr/share/openstack-tripleo-heat-templates/environments/low-memory-usage.yaml    \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    --validation-warnings-fatal   \
    --ntp-server clock.redhat.com \
    --compute-scale 1 --control-scale 3 --ceph-storage-scale 3 \
    -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
    -e ceph.yaml
