# Work log

This is a work log made by Erik Sundell, it is meant to provide insights into the steps I took along the way to reach the desired outcome.

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
