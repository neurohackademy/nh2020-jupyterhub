![deploy-gke](https://github.com/neurohackademy/nh2020-jupyterhub/workflows/deploy-gke/badge.svg)
![deploy-book](https://github.com/neurohackademy/nh2020-jupyterhub/workflows/deploy-book/badge.svg)

# Infra and documentation for NeuroHackademy's JupyterHub

[hub.neurohackademy.org](https://hub.neurohackademy.org) is a JupyterHub to be
used by instructors and students of the NeuroHackademy.org course 2020, where
the documentation on how to use it is available at
[neurohackademy.github.io/nh2020-jupyterhub](https://neurohackademy.github.io/nh2020-jupyterhub).

## Repo content

The Helm chart in [./chart](chart) is automatically built and deployed to
[hub.neurohackademy.org](https://hub.neurohackademy.org) and the
[jupyter-book](https://jupyterbook.org) in [./book](book) is automatically built
and deployed to
[neurohackademy.github.io/nh2020-jupyterhub](https://neurohackademy.github.io/nh2020-jupyterhub).

The automation for this is defined in
[.github/workflows/deploy-gke](github/workflows/deploy-gke) and
[.github/workflows/deploy-book](github/workflows/deploy-book). The automation
relies on [mozilla/sops](https://github.com/mozilla/sops) and
[yuvipanda/hubploy](https://github.com/yuvipanda/hubploy).
