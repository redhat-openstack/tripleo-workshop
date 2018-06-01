Upgrade lab
===========

Prerequisites
-------------

* Have a deployed stable/queens undercloud with free nodes for at
  least 3 controllers and 1 compute.

Recommendations
---------------

You could in theory just run the scripts, but it's recommended to open
them and run the commands manually to get more familiarity with the
workflow.

Steps
-----

* `01-get-pike-templates.sh` - Fetch Pike tripleo-heat-templates and
  create an environment file with definition of the Pike overcloud.

* `02-get-pike-images.sh` - Fetch Pike overcloud machine image and
  Pike container images.

* `03-deploy-pike-overcloud.sh` - Deploy Pike overcloud using Queens
  undercloud.

* `04-get-queens-images.sh` - Fetch Queens container images.

* `05-queens-upgrade-prepare.sh` - Run `upgrade prepare` for upgrade
  to Queens.

* `06-queens-upgrade-run.sh` - Upgrade to Queens, first all
  controllers, then compute.

* `07-queens-upgrade-converge.sh` - Run `upgrade converge`, concluding
  the upgrade to Queens.
