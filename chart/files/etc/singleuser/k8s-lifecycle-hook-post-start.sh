#/bin/bash
# This script is configured to run with a k8s postStart lifecycle hook and must
# be very robust, a failure leads to failure for the user pod to start. This is
# also a script very hard to debug because its stdout output is discarded on
# success and only available on failures which we want to avoid at all cost.

# Sync the ~/curriculum folder from the cached git repo at /nh/curriculum. This
# way, we avoid reliance on GitHub and can manage a large amount of users at
# thte same time trying to access GitHub from a limited IP range that could be
# throttled. We fallback to using GitHub though.
gitpuller /nh/curriculum master /home/jovyan/curriculum || gitpuller https://github.com/neurohackademy/nh2020-curriculum.git master /home/jovyan/curriculum || exit
