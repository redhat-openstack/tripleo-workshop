A few examples using process templates for composable roles/custom networks
##############################################################################

The tool ``process-templates.py`` in ``THT/tools/`` is handy when developing
tripleo templates. It can be used to render the jinja templates into plain heat
templates using ``roles_data.yaml`` and ``network_data.yaml`` as input.

It is also very useful to get a baseline to customize. Notice how it renders
the ``nic-config`` files for ``multiple-nics``, ``bond-with-vlans``,
``single-nic-linux-bridge-vlans`` and ``single-nic-vlans``. (Very handy to get
these rendered with all custom networks and correct vlan's and things before
hand editing them to get to something that works with the exact env.)

.. NOTE:: Unfortunately the ``--output-dir`` option does not seem to work.

::

  usage: process-templates.py [-h] [-p BASE_PATH] [-r ROLES_DATA]
                              [-n NETWORK_DATA] [--safe] [-o OUTPUT_DIR] [-c]
                              [-d]

  Configure host network interfaces using a JSON config file format.

  optional arguments:
    -h, --help            show this help message and exit
    -p BASE_PATH, --base_path BASE_PATH
                          base path of templates to process.
    -r ROLES_DATA, --roles-data ROLES_DATA
                        relative path to the roles_data.yaml file.
    -n NETWORK_DATA, --network-data NETWORK_DATA
                          relative path to the network_data.yaml file.
    --safe                Enable safe mode (do not overwrite files).
    -o OUTPUT_DIR, --output-dir OUTPUT_DIR
                          Output dir for all the templates
    -c, --clean           clean the templates dir by deleting generated
                          templates
    -d, --dry-run         only output file names normally generated from j2
                          templates


#. Ensure ``python-jinja2`` package is installed

   ::

     # RHEL / CentOS
     yum install python-jinja2

     # Fedora
     dnf install python-jinja2

#. Render the templates for Controller1 role used in the networks lab

   ::

     cd /tmp
     mkdir tht-processed
     git clone https://github.com/redhat-openstack/tripleo-workshop.git
     git clone https://git.openstack.org/openstack/tripleo-heat-templates
     cd /tmp/tripleo-heat-templates
     git checkout -t origin/stable/queens
     cd /tmp

     python ./tripleo-heat-templates/tools/process-templates.py \
       --base_path  /tmp/tripleo-heat-templates \
       --roles-data /tmp/tripleo-workshop/networking/overcloud/roles/Controller1.yaml \
       --network-data /tmp/tripleo-workshop/networking/overcloud/templates/network_data.yaml

#. Have a look at some of the files rendered

   #. Controller1 Role NIC templates

      ::

        less /tmp/tripleo-heat-templates/network/config/multiple-nics/controller1.yaml

        less /tmp/tripleo-heat-templates/network/config/multiple-nics/controller1.yaml

        less /tmp/tripleo-heat-templates/network/config/single-nic-linux-bridge-vlans/controller1.yaml

        less /tmp/tripleo-heat-templates/network/config/single-nic-vlans/controller1.yaml



   #. Network environment for IPv4 and for IPv6::

        less /tmp/tripleo-heat-templates/environments/network-environment.yaml
        less /tmp/tripleo-heat-templates/environments/network-environment-v6.yaml


   #. The Controller1 role templates

      ::

         less /tmp/tripleo-heat-templates/puppet/controller1-role.yaml

#. Clean up rendered files

   ::

      python ./tripleo-heat-templates/tools/process-templates.py \
        --base_path  /tmp/tripleo-heat-templates \
        --clean
