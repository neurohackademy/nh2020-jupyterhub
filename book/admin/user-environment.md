# Updating the user environment

Users visiting https://hub.neurohackademy.org get to work within an instance of
a Docker image (Docker container). By updating the image, you can for example
make participants get a python package you know they may need pre-installed.
Updating this image isn't so complicated thanks to automation.

```{margin}
A configuration reference is available
[here](https://repo2docker.readthedocs.io/en/latest/config_files.html), it is
the same as for BinderHubs like mybinder.org.
```

To update the Docker image, the only thing you have to do is to update [this
configuration](https://github.com/neurohackademy/nh2020-jupyterhub/tree/master/deployments/hub-neurohackademy-org/image)
by submitting a Pull Request. If a PR is merged automation will kick in, and you
can [track it
here](https://github.com/neurohackademy/nh2020-jupyterhub/actions). First the
tool [`repo2docker`](https://repo2docker.readthedocs.io) will be used to build a
new image, if that succeeds https://hub.neurohackademy.org will get updated so
that any new users starting up following this will make use of the new image.
