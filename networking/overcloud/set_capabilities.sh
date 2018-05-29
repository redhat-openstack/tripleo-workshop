#!/bin/bash

source /home/stack/stackrc

openstack baremetal node set --property capabilities='profile:control1,boot_option:local' overcloud-controller-0
openstack baremetal node set --property capabilities='profile:control1,boot_option:local' overcloud-controller-1
openstack baremetal node set --property capabilities='profile:control1,boot_option:local' overcloud-controller-2

openstack baremetal node set --property capabilities='profile:compute1,boot_option:local' overcloud-compute1-0
openstack baremetal node set --property capabilities='profile:compute2,boot_option:local' overcloud-compute2-0
openstack baremetal node set --property capabilities='profile:compute3,boot_option:local' overcloud-compute3-0

openstack baremetal node set --property capabilities='profile:ceph1,boot_option:local' overcloud-ceph1-0
openstack baremetal node set --property capabilities='profile:ceph2,boot_option:local' overcloud-ceph2-0
openstack baremetal node set --property capabilities='profile:ceph3,boot_option:local' overcloud-ceph3-0