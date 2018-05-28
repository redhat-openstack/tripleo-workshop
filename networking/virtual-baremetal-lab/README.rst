tripleo-workshop - networking
#############################

1. Install tripleo repos

   Get the url for the ``python2-tripleo-repos`` to rpm available in this repo:
   `https://trunk.rdoproject.org/centos7/current/ <https://trunk.rdoproject.org/centos7/current/>`_.

   ::

     yum -y install <url-to-python2-tripleo-repos-rpm>

#. Set up repos for stable-queens.

   ::

     tripleo-repos -b queens current

#. Install group  ``Virtualization Host``

   ::

     yum -y groupinstall 'Virtualization Host'

#. Install VirtualBMC, OpenvSwtich, some virt tools and dhcp relay agent

   ::

     yum -y install python2-setuptools python-virtualbmc openvswitch virt-install libguestfs-tools libguestfs-xfs dhcp

#. Clone labs git repo.

   ::

     git clone git@github.com:redhat-openstack/tripleo-workshop.git

#. Deploy virtual baremetal network infra config.

   Deploy configuration files for bridges and interfaces as well as systemd
   unit file for dhcprelay service.

   ::

     scp -r ./tripleo-workshop/networking/virtual-baremetal-lab/root/* /
     systemctl restart network
     systemctl restart firewalld

     # Make the script executable
     chmod +x /usr/local/bin/generate_instackenv.py

   .. NOTE:: Patience, the network restart does take long ...

#. Enable ip routing.

   ::

     cat << EOF >  /etc/sysctl.d/90-ip-forwarding.conf
     net.ipv4.ip_forward = 1
     EOF

     sysctl --system

#. Enable dhcp relay service on ctlplane networks.

   ::

     systemctl daemon-reload
     sudo systemctl enable dhcrelay.service
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

#. Create undercloud vm.

   ::

     cd /var/lib/libvirt/images/
     # Download and decompress CentOS Cloud image
     curl -O https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2.xz
     unxz CentOS-7-x86_64-GenericCloud.qcow2.xz

     # Create a new image for undercloud
     qemu-img create -f qcow2 undercloud.qcow2 40G

     # Clone and resize the CentOS cloud image to our 40G undercloud image
     virt-resize --expand /dev/sda1 CentOS-7-x86_64-GenericCloud.qcow2 undercloud.qcow2

     # Set the root password
     virt-customize -a undercloud.qcow2 --root-password password:Redhat01

     # Create config drive
     ssh-keygen

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

     genisoimage -o undercloud-config.iso -V cidata -r \
       -J /tmp/cloud-init-data/meta-data /tmp/cloud-init-data/user-data

     # Launch the undercloud vm
     #virt-install --ram 16384 --vcpus 4 --os-variant centos7.0 \
     virt-install --ram 2048 --vcpus 4 --os-variant centos7.0 \
     --disk path=/var/lib/libvirt/images/undercloud.qcow2,device=disk,bus=virtio,format=qcow2 \
     --disk path=/var/lib/libvirt/images/undercloud-config.iso,device=cdrom \
     --import --noautoconsole --vnc \
     --network network:default \
     --network network:ctlplane,portgroup=ctlplane0 \
     --name undercloud


     # Get the IP address of the undercloud
     virsh domifaddr undercloud

#. SSH to the undercloud

   ::

     ssh root@<undercloud-ip>

#. Install undercloud

   Set the hostname::

    hostnamectl set-hostname undercloud.example.com
    hostnamectl set-hostname --transient undercloud.example.com
    cat << EOF > /etc/hosts
    127.0.0.1   undercloud.exeample.com undercloud localhost localhost.localdomain localhost4 localhost4.localdomain4
    ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
    EOF


   Reference the
   `documentation <https://docs.openstack.org/tripleo-docs/latest/install/installation/installation.html>`_
   and install stable/queens undercloud using the following undercloud
   configuration (``undercloud.conf``)::

     [DEFAULT]

     undercloud_hostname = undercloud.example.com
     local_ip = 172.20.0.1/26
     undercloud_public_host = 172.20.0.2
     undercloud_admin_host = 172.20.0.3
     # or the libvirt hosts dnsmasq ...
     undercloud_nameservers = 8.8.8.8
     undercloud_ntp_servers = 0.cz.pool.ntp.org,1.cz.pool.ntp.org

     subnets = ctlplane0,ctlplane1,ctlplane2,ctlplane3
     local_subnet = ctlplane0

     local_interface = eth1
     local_mtu = 1500
     inspection_interface = br-ctlplane
     scheduler_max_attempts = 3
     enable_routed_networks = true

     [ctlplane0]
     cidr = 172.20.0.0/26
     gateway = 172.20.0.62
     dhcp_start = 172.20.0.10
     dhcp_end = 172.20.0.29
     inspection_iprange = 172.20.0.30,172.20.0.49
     masquerade = true

     [ctlplane1]
     cidr = 172.20.0.64/26
     gateway = 172.20.0.126
     dhcp_start = 172.20.0.80
     dhcp_end = 172.20.0.99
     inspection_iprange = 172.20.0.100,172.20.0.119
     masquerade = true

     [ctlplane2]
     cidr = 172.20.0.128/26
     gateway = 172.20.0.190
     dhcp_start = 172.20.0.140
     dhcp_end = 172.20.0.159
     inspection_iprange = 172.20.0.170,172.20.0.189
     masquerade = true

     [ctlplane3]
     cidr = 172.20.0.192/26
     gateway = 172.20.0.254
     dhcp_start = 172.20.0.200
     dhcp_end = 172.20.0.219
     inspection_iprange = 172.20.0.230,172.20.0.249
     masquerade = true

#. Build overcloud images and upload them

   Reference the
   `documentation and build overcloud images
   <https://docs.openstack.org/tripleo-docs/latest/install/basic_deployment/basic_deployment_cli.html#get-images>`_.

   .. Note:: If using ceph make sure to use the luminous repo.

   ::

     export DIB_YUM_REPO_CONF="/etc/yum.repos.d/delorean*"
     export DIB_YUM_REPO_CONF="$DIB_YUM_REPO_CONF /etc/yum.repos.d/tripleo-centos-ceph-luminous.repo"

   Reference the
   `documentation and upload overcloud images in the undercloud
   <https://docs.openstack.org/tripleo-docs/latest/install/basic_deployment/basic_deployment_cli.html#upload-images>`_.


#. Copy instack-env.json to the undercloud

   ::

     scp instackenv.json stack@<undercloud-ip>:

#. Register nodes

   Reference the
   `documentation to register nodes
   <https://docs.openstack.org/tripleo-docs/latest/install/basic_deployment/basic_deployment_cli.html#register-nodes>`_
   using ``instackenv.json`` that was generated and copied
   to the undercloud in previous steps.

   .. NOTE:: If the ip-address of the libvirt bridge is not ``192.168.122.1``
             make sure to update instackenv.json prior to registering the
             nodes.

#. Introspect Nodes

   Reference the
   `documentation and introspect all the nodes
   <https://docs.openstack.org/tripleo-docs/latest/install/basic_deployment/basic_deployment_cli.html#introspect-nodes>`_.
