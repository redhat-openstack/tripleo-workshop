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

To complete the lab read and run [deploy-config-download.sh](deploy-config-download.sh) 
Answer the optional questions to test your understanding.

- Read [deploy-config-download.sh](deploy-config-download.sh) and execute it so that only the HEAT section runs
- While the deployment is running, observe the difference between the Queens and Master (Rocky) versions:
  - In Queens what does '--config-download' do?
  - In Queens what does config-download-environment.yaml do?
  - In Master (Rocky) what does '--no-config-download' do?
  - Why does Master (Rocky) not use config-download-environment.yaml?
- After the deployment runs, run only the items in the DOWN section and verify you have a working ansible inventory in tripleo-config-downloadto run ad hoc commands
- Run the CONF section to configure your overcloud
- While the overcloud is being configured by Ansible, read the playbooks:
  - Read tripleo-config-download/deploy_steps_playbook.yaml first
  - Are we still using step-wise deployments?
  - How do the Ansible roles align to the default roles and what do you think would happen if we composed roles?
  - Why do we only have group_vars for two roles?
