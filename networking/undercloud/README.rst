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
   and install stable/queens python-tripleoclient.

   ::

     useradd stack
     passwd stack

     echo "stack ALL=(root) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/stack
     chmod 0440 /etc/sudoers.d/stack

     su - stack

     sudo yum -y install https://trunk.rdoproject.org/centos7/current/python2-tripleo-repos-0.0.1-0.20180418175107.ef4e12e.el7.centos.noarch.rpm
     sudo -E tripleo-repos -b queens current ceph

     sudo yum install -y python-tripleoclient

#. Clone the git repo

   ::

     git clone https://github.com/redhat-openstack/tripleo-workshop.git

#. Copy the undercloud configuration file from the git repo

   ::

     cp ./tripleo-workshop/networking/undercloud/undercloud.conf .

#. Install the undercloud

   ::

     openstack undercloud install

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

   .. NOTE:: The introspection will fail. Try to figure it out. First on to
             solve it can put the solution in the etherpad.

#.  Move on to set up `overcloud <https://github.com/redhat-openstack/tripleo-workshop/tree/master/networking/overcloud>`_.