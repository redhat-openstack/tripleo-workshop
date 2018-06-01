#!/bin/bash

source stackrc

set -euxo pipefail
cd $HOME

RELEASE=queens
THT="/usr/share/openstack-tripleo-heat-templates"

if [ -z "${NTP_SERVER:-}" ]; then
    echo "Set NTP_SERVER"
    exit 1
fi

openstack overcloud upgrade converge \
    --templates $THT \
    --libvirt-type qemu \
    -e $THT/environments/docker.yaml \
    -e $THT/environments/docker-ha.yaml \
    -e $THT/environments/low-memory-usage.yaml \
    -e $THT/environments/debug.yaml \
    -e $HOME/basic-deployment.yaml \
    -e $HOME/${RELEASE}-container-params.yaml \
    --control-scale 3 \
    --compute-scale 1 \
    --ntp-server "$NTP_SERVER" \

    # --no-config-download  # only for master undercloud
