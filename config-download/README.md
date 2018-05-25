# config-download lab

Before TripleO had the [config-download](https://docs.openstack.org/tripleo-docs/latest/install/advanced_deployment/ansible_config_download.html) feature, a user took the following steps:

- Describe the deployment in TripleO Heat Templates (THT)
- Run _openstack overcloud deploy ... -e featureX.yaml -e featureY.yaml ..._
- Observe Heat interfacing with Nova/Ironic to deploy the hardware
- Observe Heat applying configuration via os-collect-config

The config-download feature changes how the last of the above
works so that it could be described as the following:

- Describe the deployment in TripleO Heat Templates (THT)
- Run _openstack overcloud deploy ... -e featureX.yaml -e featureY.yaml ..._
- Observe Heat interfacing with Nova/Ironic to deploy the hardware
- _Download the configuration data as Ansible playbooks_
- _Observe the undercloud running the playbooks to configure the overcloud_

To appreciate the difference of the above, we'll do a two-node
deployment but instead of having Mistral execute the last two steps, 
we will pass the tripleo client options so that we run them manually.
