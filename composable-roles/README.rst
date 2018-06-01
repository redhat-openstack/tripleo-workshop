A few examples for composable roles
###################################

#. OOO ships with quite a few default roles. You can view them using the CLI:

   ::

        openstack overcloud role list

#. If you want to use a custom environment with some of the roles, do the
   following:

   ::

        openstack overcloud roles generate -o my_roles.yaml Controller ObjectStorage

#. Now deploy these roles using by using your custom role definition:

   ::

        openstack overcloud deploy --templates [...] -r custom_roles.yaml --compute-scale 0 --control-scale 1 --swift-storage-scale 1

#. You can also modify the generated YAML file, and remove more service that
   you don't want to be deployed. This is sometimes useful if you're working
   only on a specific service, and just want to test this service. In most
   cases you will need a few additional services like Keystone, MariaDB
   (MySQL), HAProxy. A good starting point is to remove other OpenStack
   services and keeping the remaining services. Have a look at the
   swift_only.yaml for an example.

#. There is another role to prepare a two-node Kubernetes overcloud, which is quite nice to do some
   testing. Deploy this with:

   ::

        openstack overcloud deploy --templates -e /usr/share/openstack-tripleo-heat-templates/environments/kubernetes.yaml -r kubernetes.yaml

        # Workaround
        sudo yum install -y python-pip
        sudo pip install ansible-modules-hashivault

        # Now deploy with kubespray
        tripleo-config-download -s overcloud -o ~/config-download
        ansible-playbook -i /usr/bin/tripleo-ansible-inventory ~/config-download/tripleo-*/deploy_steps_playbook.yaml

        # Log into the controller node and check kubernetes nodes
        nova ssh --network ctlplane --address-type fixed --login heat-admin overcloud-controller-0
        kubectl get nodes
