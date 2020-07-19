#!/bin/bash

# 0: Explanation -------------------------------------------------------------
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
# ----------------------------------------------------------------------------



# 1: /etc/skel/.bashrc -------------------------------------------------------
# Note the order below of sourcing /etc/skel/.bashrc before /etc/skel/.profile
# is to mimic that the first thing ~/.profile will do is to invoke ~/.bashrc,
# after which it continues its execution.
. /etc/skel/.bashrc
# -----------------------------------------------------------------------------



# 2: Custom styling ----------------------------------------------------------
# The following section is copied and injected from an Ubuntu 18.04
# /etc/skel/.bashrc file to style things
#
# CHANGES:
# - removed comment from force_color_prompt=yes
# - removed /h from PS1
# - removed "\u@\h: " from the xterm title section
# -----------------------------------------------------------------------------

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\w\a\]$PS1"
    ;;
*)
    ;;
esac
# -----------------------------------------------------------------------------



# 3: /etc/skel/.profile ------------------------------------------------------
# /etc/skel/.profile only sources ~/.bashrc and appends user local directories
# to the PATH environment variable.
. /etc/skel/.profile
# -----------------------------------------------------------------------------



# Following this, a login shell will execute the first of ~/.bash_profile,
# ~/.bash_login, and ~/.profile I think.
