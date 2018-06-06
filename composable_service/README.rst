A composable service example
############################

This example is based on the demo Docker container exposing a netcat service,
returning the current date on the node.

#. First you need to build the container and push it to the undercloud registry:

   ::
        
        docker build . -t 192.168.24.1:8787/sample_service
        docker push 192.168.24.1:8787/sample_service

#. Now you need to deploy with a custom environment. Note that the used
   environment removes all services from the Controller node except Docker. You
   need to start using a clean state, thus you have to delete your current
   overcloud deployment (or add all controller services to the environment).

   ::

        openstack overcloud deploy --templates -e /usr/share/openstack-tripleo-heat-templates/environments/docker.yaml -e env.yaml --compute-scale 0

#. There should be a single running container on the controller node after
   deployment: 

   ::
        
        [heat-admin@overcloud-controller-0 ~]$ sudo docker ps
        CONTAINER ID        IMAGE                                     COMMAND                CREATED             STATUS              PORTS               NAMES
        b112edd64c7c        192.168.24.1:8787/sample_service:latest "/usr/bin/ncat -l ..."   9 hours ago         Up 9 hours                              sample_service

#. When sending a GET request to the container, it should return the current
   date:

   ::
        
        [heat-admin@overcloud-controller-0 ~]$ curl http://127.0.0.1:2222
        Wed Jun  6 06:45:02 UTC 2018
