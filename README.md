## A Dockerless Image Facade !

This is an example of an image facade plugin to the blackduck perceptor framework.

To use it, you can customize the mockimagefacade.go class with logic specific to the

images that your interested in.

## Implementing your own image facade.

- create a container which implements the pullimage and checkimage REST endpoints, as done in this repo.  For details on how to implement these API endpoints, either look in the code here, or checkout https://github.com/blackducksoftware/opssight-connector/wiki/Opssight-Images. 

- push your container to a repository, for example "gcr.io/mydockerrepo/mycompany/imagefacade:latest".

- Then modify your `image-registry.json`, so that the 'perceptor-imagefacade' json field has image equal to "imagefacade" with tag equal to "latest".

- For opssight connector, run `./install.sh -c gcr.io -I mydockerrepo/mycompany -H myhub.myorg.com -U sysadmin -W mypassword -P 443 --hub-max-concurrent-scans=1`

- You now should be able to see your custom image facade being called by the perceptor scanner container!

# This repository is just a simple example of how to implement an image facade.  It is not a product nor something we recommend running in a production environment.

## The implementation in this repo

In this example, we actually use an openshift client to copy (using oc cp) specific

bits and peices of images that we want to scan.  Why?  Simply because it allows us

to demonstrate 2 things:

- Perceptor is capable of *more then just scanning static images*.  It can easily tell you about
realtime changes to the source code in your running applications.

- Perceptor is *not dependent on docker, or root, for any core functionality*, and you can plug in your
own image facade components easily, which allows you to run it in your entire data center WITHOUT
ever needing a privileged container, and also without allowing any docker socket mounting functionality.

## Extending

The example here most likely will not have a 1-1 mapping with your organizations specific scanning
needs, so you'll definetly want to extend it or simply check the code out, to learn from it.

If the former, and for questions on how to implement an image facade for your specific needs, contact blackduck support, or file a github
issue in the perceptor upstream project.

## Hacking

Borrow bits and peices from the cloudbuild.yaml to setup a build pipeline as needed, modify imagefacade.go (easy to rewrite in another language, just make sure you implement the 2 REST endpoints), and be on your way !
