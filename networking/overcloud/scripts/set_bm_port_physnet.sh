#!/bin/bash

source /home/stack/stackrc

openstack baremetal port set --physical-network ctlplane1 $(openstack baremetal port list --node overcloud-controller-0 -f value -c UUID)
openstack baremetal port set --physical-network ctlplane1 $(openstack baremetal port list --node overcloud-controller-1 -f value -c UUID)
openstack baremetal port set --physical-network ctlplane1 $(openstack baremetal port list --node overcloud-controller-2 -f value -c UUID)

openstack baremetal port set --physical-network ctlplane1 $(openstack baremetal port list --node overcloud-compute1-0 -f value -c UUID)
openstack baremetal port set --physical-network ctlplane2 $(openstack baremetal port list --node overcloud-compute2-0 -f value -c UUID)
openstack baremetal port set --physical-network ctlplane3 $(openstack baremetal port list --node overcloud-compute3-0 -f value -c UUID)

openstack baremetal port set --physical-network ctlplane1 $(openstack baremetal port list --node overcloud-ceph1-0 -f value -c UUID)
openstack baremetal port set --physical-network ctlplane2 $(openstack baremetal port list --node overcloud-ceph2-0 -f value -c UUID)
openstack baremetal port set --physical-network ctlplane3 $(openstack baremetal port list --node overcloud-ceph3-0 -f value -c UUID)
