tripleo-workshop - networking - Undercloud Installation
#######################################################

Install undercloud
------------------

#. Set the hostname

   ::

     hostnamectl set-hostname undercloud.example.com
     hostnamectl set-hostname --transient undercloud.example.com
     cat << EOF > /etc/hosts
     127.0.0.1   undercloud.exeample.com undercloud localhost localhost.localdomain localhost4 localhost4.localdomain4
     ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
     EOF


#. Reference the
   `documentation <https://docs.openstack.org/tripleo-docs/latest/install/installation/installation.html>`_
   and install stable/queens undercloud.

   Use the following undercloud configuration (``undercloud.conf``)::

     [DEFAULT]

     undercloud_hostname = undercloud.example.com
     local_ip = 172.20.0.1/26
     undercloud_public_host = 172.20.0.2
     undercloud_admin_host = 172.20.0.3
     # Change if this is not the libvirt default virbr0 interface ip
     undercloud_nameservers = 192.168.122.1
     undercloud_ntp_servers = 0.cz.pool.ntp.org,1.cz.pool.ntp.org

     subnets = ctlplane0,ctlplane1,ctlplane2,ctlplane3
     local_subnet = ctlplane0

     local_interface = eth1
     local_mtu = 1500
     inspection_interface = br-ctlplane
     scheduler_max_attempts = 3
     enable_routed_networks = true

     # Comment this if not using a docker registry mirror
     docker_registry_mirror = http://10.12.50.1:5000

     [ctlplane0]
     cidr = 172.20.0.0/26
     gateway = 172.20.0.62
     dhcp_start = 172.20.0.10
     dhcp_end = 172.20.0.29
     inspection_iprange = 172.20.0.30,172.20.0.49
     masquerade = false

     [ctlplane1]
     cidr = 172.20.0.64/26
     gateway = 172.20.0.126
     dhcp_start = 172.20.0.80
     dhcp_end = 172.20.0.99
     inspection_iprange = 172.20.0.100,172.20.0.119
     masquerade = false

     [ctlplane2]
     cidr = 172.20.0.128/26
     gateway = 172.20.0.190
     dhcp_start = 172.20.0.140
     dhcp_end = 172.20.0.159
     inspection_iprange = 172.20.0.170,172.20.0.189
     masquerade = false

     [ctlplane3]
     cidr = 172.20.0.192/26
     gateway = 172.20.0.254
     dhcp_start = 172.20.0.200
     dhcp_end = 172.20.0.219
     inspection_iprange = 172.20.0.230,172.20.0.249
     masquerade = false

#. Build overcloud images and upload them in undercloud

   Reference the
   `documentation and build overcloud images
   <https://docs.openstack.org/tripleo-docs/latest/install/basic_deployment/basic_deployment_cli.html#get-images>`_.

   .. NOTE:: If using ceph make sure to use the luminous repo
             ::

               export DIB_YUM_REPO_CONF="/etc/yum.repos.d/delorean*"
               export DIB_YUM_REPO_CONF="$DIB_YUM_REPO_CONF /etc/yum.repos.d/tripleo-centos-ceph-luminous.repo"

   Alternatively download pre-built images::

     mkdir images
     cd images

     # Download from rdoporject.org
     curl -O https://images.rdoproject.org/queens/delorean/current-tripleo/ironic-python-agent.tar
     curl -O https://images.rdoproject.org/queens/delorean/current-tripleo/ironic-python-agent.tar.md5
     curl -O https://images.rdoproject.org/queens/delorean/current-tripleo/overcloud-full.tar
     curl -O https://images.rdoproject.org/queens/delorean/current-tripleo/overcloud-full.tar.md5

     # Download from internal lab network
     curl -O http://10.12.50.1/pub/tripleo-masterclass/queens-tripleo/ironic-python-agent.tar
     curl -O http://10.12.50.1/pub/tripleo-masterclass/queens-tripleo/ironic-python-agent.tar.md5
     curl -O http://10.12.50.1/pub/tripleo-masterclass/queens-tripleo/overcloud-full.tar
     curl -O http://10.12.50.1/pub/tripleo-masterclass/queens-tripleo/overcloud-full.tar.md5

     tar xvf ironic-python-agent.tar
     tar xvf overcloud-full.tar

     openstack overcloud image upload

     cd ~

   Reference the
   `documentation and upload overcloud images in the undercloud
   <https://docs.openstack.org/tripleo-docs/latest/install/basic_deployment/basic_deployment_cli.html#upload-images>`_.


#. Copy instack-env.json to the undercloud

     scp root@192.168.122.1:instackenv.json .

#. Register nodes

   Reference the
   `documentation to register nodes
   <https://docs.openstack.org/tripleo-docs/latest/install/basic_deployment/basic_deployment_cli.html#register-nodes>`_
   using ``instackenv.json`` that was generated and copied
   to the undercloud in previous steps.

   ::

     openstack overcloud node import instackenv.json

#. Set root device hint for Ceph nodes

   ::

     openstack baremetal node set overcloud-ceph1-0 --property root_device='{"name": "/dev/vda"}'
     openstack baremetal node set overcloud-ceph2-0 --property root_device='{"name": "/dev/vda"}'
     openstack baremetal node set overcloud-ceph3-0 --property root_device='{"name": "/dev/vda"}'

#. Introspect Nodes

   Reference the
   `documentation and introspect all the nodes
   <https://docs.openstack.org/tripleo-docs/latest/install/basic_deployment/basic_deployment_cli.html#introspect-nodes>`_.

   ::

     openstack overcloud node introspect --all-manageable

#.  Move on to set up `overcloud <https://github.com/redhat-openstack/tripleo-workshop/tree/master/networking/overcloud>`_.