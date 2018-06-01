#!/bin/bash

source stackrc

set -euxo pipefail
cd $HOME

openstack overcloud upgrade run --roles Controller

openstack overcloud upgrade run --nodes overcloud-novacompute-0

# add  --skip-tags validation  if re-running after failure
# to not fail because services are stopped
