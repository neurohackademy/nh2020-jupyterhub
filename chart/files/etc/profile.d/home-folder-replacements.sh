#!/bin/bash

# Since we replace the entire home folder for our user, we loose our shell
# configuration files .bashrc and .profile that is created from
# /etc/skel/.bashrc and /etc/skel/.profile when the user was created. One way to
# resolve this is to copy those folders on first startup, another solution is to
# invoke the skeleton files from a script in the /etc/profile.d folder. This is
# such script which we will mount into /etc/profile.d.
#
# The typical execution order of files would be /etc/profile and ~/.profile for
# a login shell, but ~/.profile will be missing, and it would call ~/.bashrc
# which will also be missing. Due to that we run both /etc/skel/.profile and
# /etc/skel/.bashrc.
#
#   /etc/profile
#       /etc/bash.bashrc
#       /etc/profile.d/*.sh
#   ~/.profile    - a copy of /etc/skel/.profile
#       ~/.bashrc - a copy of /etc/skel/.bashrc
#
# Note the order below is like this to mimic that the first thing ~/.profile
# will do is to invoke ~/.bashrc, after which it continues its execution.
. /etc/skel/.bashrc
. /etc/skel/.profile
