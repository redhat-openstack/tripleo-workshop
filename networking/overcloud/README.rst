tripleo-workshop - networking - Overcloud Installation
######################################################

#. Clone the git repo

   ::

     git clone https://github.com/redhat-openstack/tripleo-workshop.git

#. Copy templates, roles, environments and scripts from git repo

   scp -r ./tripleo-workshop/networking/overcloud/* /home/stack/

#. Create flavors

   ::

     bash create_flavors.sh

#. Set baremetal node capabilities

   ::

     bash set_capabilities.sh

#. Configure baremetal node port's physical network

   ::

     bash set_bm_port_physnet.sh


#. Create roles data

   ::

     openstack overcloud roles generate \
       --roles-path ~/roles \
       -o ~/templates/roles_data.yaml \
       Controller1 \
       Compute1 Compute2 Compute3 \
       Ceph1 Ceph2 Ceph3

#. Prepare docker images

#. Deploy the overcloud

   ::

     time bash deploy_overcloud.sh


