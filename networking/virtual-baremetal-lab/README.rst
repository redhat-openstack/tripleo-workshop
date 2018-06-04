tripleo-workshop - networking - Virtual Baremetal Lab
#####################################################

Pre-requirements
----------------

RHEL 7 or CentOS 7 baremtal machine with a lot of memory and some disks.

Lab infrastructure
------------------

Hypervisor bridges
==================

- **br-ctlplane**

  This bride hosts the ctlplane network VLAN's.

- **br-trunk**

  This bridge hosts external, storage, storagemgmt, internal and tenant
  networks.

Overcloud Control Plane Networks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+---------------+-----------------+---------------+-----------+--------------+
| Network       | IP/Prefix       | Gateway       |VLAN ID    | OVS Bridge   |
+===============+=================+===============+===========+==============+
| ctlplane0     | 172.20.0.0/26   | 172.20.0.62   | 600       | br-ctlplane  |
+---------------+-----------------+---------------+-----------+--------------+
| ctlplane1     | 172.20.0.64/26  | 172.20.0.126  | 601       | br-ctlplane  |
+---------------+-----------------+---------------+-----------+--------------+
| ctlplane2     | 172.20.0.128/26 | 172.20.0.190  | 602       | br-ctlplane  |
+---------------+-----------------+---------------+-----------+--------------+
| ctlplane3     | 172.20.0.192/26 | 172.20.0.254  | 603       | br-ctlplane  |
+---------------+-----------------+---------------+-----------+--------------+

Overcloud External Networks
~~~~~~~~~~~~~~~~~~~~~~~~~~~

+---------------+-----------------+---------------+-----------+--------------+
| Network       | IP/Prefix       | Gateway       |VLAN ID    | OVS Bridge   |
+===============+=================+===============+===========+==============+
| external1     | 172.20.2.64/26  | 172.20.2.126  | 621       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+


Overcloud StorageMgmt Networks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+---------------+-----------------+---------------+-----------+--------------+
| Network       | IP/Prefix       | Gateway       |VLAN ID    | OVS Bridge   |
+===============+=================+===============+===========+==============+
| storagemgmt0  | 172.20.0.0/26   | 172.20.4.62   | 640       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+
| storagemgmt1  | 172.20.0.64/26  | 172.20.4.126  | 641       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+
| storagemgmt2  | 172.20.0.128/26 | 172.20.4.190  | 642       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+
| storagemgmt3  | 172.20.0.192/26 | 172.20.4.254  | 643       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+

Overcloud Storage Networks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+---------------+-----------------+---------------+-----------+--------------+
| Network       | IP/Prefix       | Gateway       |VLAN ID    | OVS Bridge   |
+===============+=================+===============+===========+==============+
| storage0      | 172.20.3.0/26   | 172.20.3.62   | 630       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+
| storage1      | 172.20.3.64/26  | 172.20.3.126  | 631       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+
| storage2      | 172.20.3.128/26 | 172.20.3.190  | 632       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+
| storage3      | 172.20.3.192/26 | 172.20.3.254  | 633       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+

Ovecloud Internal Api Networks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+---------------+-----------------+---------------+-----------+--------------+
| Network       | IP/Prefix       | Gateway       |VLAN ID    | OVS Bridge   |
+===============+=================+===============+===========+==============+
| intapi0       | 172.20.1.0/26   | 172.20.1.62   | 610       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+
| intapi1       | 172.20.1.64/26  | 172.20.1.126  | 611       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+
| intapi2       | 172.20.1.128/26 | 172.20.1.190  | 612       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+
| intapi3       | 172.20.1.192/26 | 172.20.1.254  | 613       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+

Ovecloud Tenant Networks
~~~~~~~~~~~~~~~~~~~~~~~~

+---------------+-----------------+---------------+-----------+--------------+
| Network       | IP/Prefix       | Gateway       |VLAN ID    | OVS Bridge   |
+===============+=================+===============+===========+==============+
| tenant0       | 172.20.5.0/26   | 172.20.5.62   | 650       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+
| tenant1       | 172.20.5.64/26  | 172.20.5.126  | 651       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+
| tenant2       | 172.20.5.128/26 | 172.20.5.190  | 652       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+
| tenant3       | 172.20.5.192/26 | 172.20.5.254  | 653       | br-trunk     |
+---------------+-----------------+---------------+-----------+--------------+

Libvirt networks
================

+---------------+--------------+--------------+-------------------+
| Name          | Bridge       | PortGroup(s) | Vlan(s)           |
+===============+==============+==============+===================+
| **ctlplane**  | br-ctlplane  | ctlplane0    | 600 (untagged)    |
+---------------+--------------+--------------+-------------------+
|               |              | ctlplane1    | 601 (untagged)    |
+------------------------------+--------------+-------------------+
|               |              | ctlplane2    | 602 (untagged)    |
+------------------------------+--------------+-------------------+
|               |              | ctlplane3    | 603 (untagged)    |
+---------------+--------------+--------------+-------------------+
| **default**   | virbr0       | N/A          | N/A               |
+---------------+--------------+--------------+-------------------+
| **trunk**     | br-trunk     | trunk        | 610-613, (tagged) |
+---------------+--------------+--------------+-------------------+
|                                             | 620-623, (tagged) |
+---------------------------------------------+-------------------+
|                                             | 630-633, (tagged) |
+---------------------------------------------+-------------------+
|                                             | 640-643, (tagged) |
+---------------------------------------------+-------------------+
|                                             | 650-653  (tagged) |
+---------------+--------------+--------------+-------------------+



Set up the virtual baremetal lab
--------------------------------

.. NOTE:: If the node was previously used to run quickstart. Make sure all
          quickstart nodes are stopped.

          ::

            # Log in as root on the virt host
            # Change to the stack user
            su - stack
            # destroy all running vms
            for vm in $(virsh list --all | egrep 'running' | awk '{ print $2 }'); do virsh destroy $vm; done
            # Get back to root ...
            exit

1. Generate ssh keys

   ::

     ssh-keygen

#. Install tripleo repos

   Get the url for the ``python2-tripleo-repos`` to rpm available in this repo:
   `https://trunk.rdoproject.org/centos7/current/ <https://trunk.rdoproject.org/centos7/current/>`_.

   ::

     yum -y install <url-to-python2-tripleo-repos-rpm>

#. Set up repos for stable-queens.

   ::

     tripleo-repos -b queens current ceph

#. Install group  ``Virtualization Host``

   ::

     yum -y groupinstall 'Virtualization Host'

   .. NOTE:: Training lab may already have this ...

#. Install VirtualBMC, OpenvSwtich, some virt tools and dhcp relay agent

   ::

     yum -y install git python2-setuptools python-virtualbmc openvswitch virt-install libguestfs-tools libguestfs-xfs

#. Enable nested virtualization

   ::

     cat << EOF > /etc/modprobe.d/kvm_intel.conf
     options kvm-intel nested=1
     options kvm-intel enable_shadow_vmcs=1
     options kvm-intel enable_apicv=1
     options kvm-intel ept=1
     EOF

     modprobe -r kvm_intel
     modprobe kvm_intel
     cat /sys/module/kvm_intel/parameters/nested


#. Compile and install dhcrelay from ics-dhcp

   .. NOTE:: The dhcp package in RHEL/CentOS is ICS-DHCP 4.2.x. The dhcrelay
             that comes with the package is buggy. We need ICS-DHCP 4.3.x.

   ::

     # Install build dependencies
     yum -y install gcc make

     # Create a user to compile software
     useradd devuser
     su - devuser
     # Download the source, decrunch and unpack
     curl -o dhcp-4-3-6-p1.tar.gz https://www.isc.org/downloads/file/dhcp-4-3-6-p1/
     tar xvzf dhcp-4-3-6-p1.tar.gz
     cd dhcp-4.3.6-P1/
     # Configure, Compile, Install
     ./configure --prefix=/usr/local
     make
     su root
     make install

     exit
     exit


#. Clone labs git repo.

   ::

     git clone https://github.com/redhat-openstack/tripleo-workshop.git

#. Deploy virtual baremetal network infra config.

   Deploy configuration files for bridges and interfaces as well as systemd
   unit file for dhcprelay service.

   ::

     scp -r ./tripleo-workshop/networking/virtual-baremetal-lab/root/* /
     systemctl restart network

   .. NOTE:: Patience, the network restart does take long ...

   ::

     systemctl restart firewalld

     # Make the script executable
     chmod +x /usr/local/bin/generate_instackenv.py



#. Enable ip routing.

   ::

     cat << EOF >  /etc/sysctl.d/90-ip-forwarding.conf
     net.ipv4.ip_forward = 1
     EOF

     sysctl --system

#. Enable dhcp relay service on ctlplane networks.

   ::

     systemctl daemon-reload
     systemctl enable dhcrelay.service
     systemctl start dhcrelay.service
     systemctl status dhcrelay.service

#. Create libvirt networks.

   ::

     # Make sure libvirt is running
     systemctl status libvirtd.service || systemctl restart libvirtd.service

     cd ./tripleo-workshop/networking/virtual-baremetal-lab/libvirt/networks/
     bash create_networks.sh

     cd ~

#. Create disks for vms.

   ::

     cd /var/lib/libvirt/images/
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-controller-0.qcow2 60G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-controller-1.qcow2 60G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-controller-2.qcow2 60G

     qemu-img create -f qcow2 -o preallocation=metadata overcloud-compute1-0.qcow2 60G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-compute2-0.qcow2 60G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-compute3-0.qcow2 60G

     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph1-0-root.qcow2 60G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph1-0-osd0.qcow2 20G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph1-0-osd1.qcow2 20G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph1-0-osd2.qcow2 20G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph1-0-osd3.qcow2 20G

     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph2-0-root.qcow2 60G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph2-0-osd0.qcow2 20G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph2-0-osd1.qcow2 20G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph2-0-osd2.qcow2 20G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph2-0-osd3.qcow2 20G

     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph3-0-root.qcow2 60G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph3-0-osd0.qcow2 20G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph3-0-osd1.qcow2 20G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph3-0-osd2.qcow2 20G
     qemu-img create -f qcow2 -o preallocation=metadata overcloud-ceph3-0-osd3.qcow2 20G

     cd ~

#. Create overcloud vms.

   ::

     cd ./tripleo-workshop/networking/virtual-baremetal-lab/libvirt/vms
     bash create_vms.sh

     cd ~

#. Configure virtual BMC for overcloud nodes

   ::

     vbmc add --username admin --password password --port 6230 overcloud-controller-0
     vbmc add --username admin --password password --port 6231 overcloud-controller-1
     vbmc add --username admin --password password --port 6232 overcloud-controller-2
     vbmc add --username admin --password password --port 6233 overcloud-compute1-0
     vbmc add --username admin --password password --port 6234 overcloud-compute2-0
     vbmc add --username admin --password password --port 6235 overcloud-compute3-0
     vbmc add --username admin --password password --port 6236 overcloud-ceph1-0
     vbmc add --username admin --password password --port 6237 overcloud-ceph2-0
     vbmc add --username admin --password password --port 6238 overcloud-ceph3-0

     vbmc start overcloud-controller-0
     vbmc start overcloud-controller-1
     vbmc start overcloud-controller-2
     vbmc start overcloud-compute1-0
     vbmc start overcloud-compute2-0
     vbmc start overcloud-compute3-0
     vbmc start overcloud-ceph1-0
     vbmc start overcloud-ceph2-0
     vbmc start overcloud-ceph3-0

#. Generate instack-env.json

   ::

     /usr/local/bin/generate_instackenv.py > instackenv.json

   .. NOTE:: If the ip-address of the libvirt bridge is not ``192.168.122.1``
             make sure to update instackenv.json prior to registering the
             nodes.
             ::

               sed -i s/192.168.122.1/<libvirt-bridge-ip>/ instackenv.json

#. Create undercloud vm.

   ::

     cd /var/lib/libvirt/images/
     # Download and decompress CentOS Cloud image
     curl -O https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2.xz
     # curl -O http://10.12.50.1/pub/tripleo-masterclass/CentOS-7-x86_64-GenericCloud.qcow2.xz
     unxz CentOS-7-x86_64-GenericCloud.qcow2.xz

     # Create a new image for undercloud
     qemu-img create -f qcow2 netlab-undercloud.qcow2 40G

     # Clone and resize the CentOS cloud image to our 40G undercloud image
     virt-resize --expand /dev/sda1 CentOS-7-x86_64-GenericCloud.qcow2 netlab-undercloud.qcow2

     # Set the root password
     virt-customize -a netlab-undercloud.qcow2 --root-password password:Redhat01

     # Create config drive

     mkdir -p /tmp/cloud-init-data/
     cat << EOF > /tmp/cloud-init-data/meta-data
     instance-id: undercloud-instance-id
     local-hostname: undercloud.example.com
     network:
       version: 2
       ethernets:
         eth0:
           dhcp4: true
     EOF
     cat << EOF > /tmp/cloud-init-data/user-data
     #cloud-config
     disable_root: false
     ssh_authorized_keys:
       - $(cat ~/.ssh/id_rsa.pub)
     EOF

     genisoimage -o netlab-undercloud-config.iso -V cidata -r \
       -J /tmp/cloud-init-data/meta-data /tmp/cloud-init-data/user-data

     # Launch the undercloud vm
     virt-install --ram 16384 --vcpus 4 --os-variant centos7.0 \
     --disk path=/var/lib/libvirt/images/netlab-undercloud.qcow2,device=disk,bus=virtio,format=qcow2 \
     --disk path=/var/lib/libvirt/images/netlab-undercloud-config.iso,device=cdrom \
     --import --noautoconsole --vnc \
     --network network:default \
     --network network:ctlplane,portgroup=ctlplane0 \
     --name netlab-undercloud


     # Get the IP address of the undercloud
     virsh domifaddr netlab-undercloud

#. SSH to the undercloud

   ::

     ssh root@<undercloud-ip>


#. Move on to set up
   `undercloud <https://github.com/redhat-openstack/tripleo-workshop/tree/master/networking/undercloud>`_.
