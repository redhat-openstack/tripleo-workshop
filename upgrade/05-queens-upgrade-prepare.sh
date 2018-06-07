#!/bin/bash

source ~/stackrc

set -euxo pipefail
cd $HOME

RELEASE=queens
THT="/usr/share/openstack-tripleo-heat-templates"

if [ -z "${NTP_SERVER:-}" ]; then
    echo "Set NTP_SERVER"
    exit 1
fi

echo > ${RELEASE}-upgrade-repos.yaml '
parameter_defaults:
  UpgradeInitCommand: |
    yum -y install https://trunk.rdoproject.org/centos7/current/python2-tripleo-repos-0.0.1-0.20180418175107.ef4e12e.el7.centos.noarch.rpm
    tripleo-repos -b queens current
    yum clean all
'

openstack overcloud upgrade prepare \
    --templates $THT \
    --libvirt-type qemu \
    -e $THT/environments/docker.yaml \
    -e $THT/environments/docker-ha.yaml \
    -e $THT/environments/low-memory-usage.yaml \
    -e $THT/environments/debug.yaml \
    -e $HOME/basic-deployment.yaml \
    -e $HOME/${RELEASE}-container-params.yaml \
    -e $HOME/${RELEASE}-upgrade-repos.yaml \
    --control-scale 3 \
    --compute-scale 1 \
    --ntp-server "$NTP_SERVER" \

    # --no-config-download  # only for master undercloud
