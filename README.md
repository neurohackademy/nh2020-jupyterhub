![deploy-gke](https://github.com/neurohackademy/nh2020-jupyterhub/workflows/deploy-gke/badge.svg)
![deploy-book](https://github.com/neurohackademy/nh2020-jupyterhub/workflows/deploy-book/badge.svg)

# Infra and docs for hub.neurohackademy.org

hub.neurohackademy.org is a JupyterHub to be used by instructors and students of
the NeuroHackademy.org course 2020.

## Infrastructure

The Helm chart in [chart](chart) is automatically built and deployed in a GKE
cluster using [.github/workflows/deploy-gke](github/workflows/deploy-gke).
[mozilla/sops](https://github.com/mozilla/sops) and
[yuvipanda/hubploy](https://github.com/yuvipanda/hubploy) are tools used to do
this.

Access is to https://hub.neurohackademy.org is managed through the Access
Control Lists available at
[chart/files/etc/jupyterhub/acl](chart/files/etc/jupyterhub/acl).

## Documentation

Documentation about this infrastructure is automatically built and published at
https://neurohackademy.github.io/nh2020-jupyterhub/ using
[.github/workflows/deploy-book](github/workflows/deploy-book) and the
documentation in [book](book) built with
[jupyter-book](https://github.com/executablebooks/jupyter-book).
