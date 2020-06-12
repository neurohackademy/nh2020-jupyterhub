# Work log

This is a work log made by Erik Sundell. It is meant to provide insights into
the steps I take along the way to reach the desired outcome.

## Statement of work

1. Design for a scalable and configurable Jupyterhub for instruction of NeuroHackademy. The hub has the following desiderata:

    1. Scale to thousands of users on a Kubernetes cluster.
    1. Gate usage with GitHub authentication.
    1. Auto-deploy single docker image for the course with hubploy/GitHub actions.

2. Implement the solution within a Google Cloud Platform (GCP) project owned and billed by an existing eScience Google Cloud Platform account.

3. Maintain the solution and keep it running for the duration of the course.

4. To provide public documentation to help anyone create a similar bootcamp setup in the future, involving technical procedures as well as guidance on architectural decisions, at 2i2c/zero-to bootcamp. 

## A place for documentation

I created a Jupyter Book which you currently read using the
[jupyter-book](https://github.com/executablebooks/jupyter-book) CLI in order to
be able to document my work from the start.

## Architecture plans

A single repo to manage: Kubernetes deployment, documentation for
administrators/instructors/students, and the Jupyter user environment.

### Architectual decisions

#### A single user environment

For a course with many lectures, we may have conflicting environment
constraints. Due to this, it could make sense to allow lecturers build their own
environment. Me and Ariel have opted to not go that route, considerations behind
this decision included:

1. A single course will likely not need too much customization of the user
   environment between lectures, so its likely we can avoid conflicting
   dependencies in a single Docker image.

1. Its practically easier to test a single environment to work as intended
   than many.

1. When a user arrives, it should preferably not need to wait for a new server
   (Kubernetes node) to startup, and neither wait for the Docker image it needs
   to be downloaded to that server. With a single or very few docker images, it
   is far easier to ensure the user doesn't need to wait for a downloaded image
   than with for example ten different.

   When a new Kubernetes node is added the JupyterHub Helm chart allows for
   images to be pre-pulled or downloaded ahead of time before users arrive. If
   there is only one image to pull, the node will be ready far quicker than if
   we need to pull ten images. This can be a difference of two to twenty
   minutes.
