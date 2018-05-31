tripleo-workshop - networking - Overcloud Installation
######################################################

#. Clone the git repo

   ::

     git clone https://github.com/redhat-openstack/tripleo-workshop.git

#. Copy templates, roles, environments and scripts from git repo

   scp -r ./tripleo-workshop/networking/overcloud/* /home/stack/

#. Create flavors

   ::

     bash ./scripts/create_flavors.sh

#. Set baremetal node capabilities

   ::

     bash ./scripts/set_capabilities.sh

#. Configure baremetal node port's physical network

   ::

     bash ./scripts/set_bm_port_physnet.sh


#. Create roles data

   ::

     openstack overcloud roles generate \
       --roles-path /home/stack/roles \
       -o /home/stack/templates/roles_data.yaml \
       Controller1 Compute1 Compute2 Compute3 Ceph1 Ceph2 Ceph3

#. Prepare docker images

   ::

     openstack overcloud container image prepare \
       --namespace 10.12.50.1/triplequeens \
       --tag current-tripleo \
       --output-env-file /home/stack/environments/docker_registry.yaml \
       --output-images-file /home/stack/templates/overcloud_containers.yaml

#. Deploy the overcloud

   ::

     time bash deploy_overcloud.sh


