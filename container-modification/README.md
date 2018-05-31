Modifying a Docker container in TripleO
#######################################

#. Let's assume you want to make a modification to an existing container, for
   example to apply an patch to one of the services. In this case you create a
   Dockerfile with the required commands to execute, and rebuild the container:

   ::

        sudo docker build --rm -t 192.168.24.1:8787/tripleoqueens/centos-binary-swift-proxy-server:fix .

#. Now use the modified container by deploying with the additional environment
   file:

   ::

        openstack overcloud deploy --templates [...] -e use-modified-container.yaml

#. If you used the patch from this directory, you should get a slightly
   modified response from the Swift proxy server when sending a GET request to
   /info:

   ::

        source overcloudrc && swift info
