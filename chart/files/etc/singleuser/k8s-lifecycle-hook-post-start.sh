#/bin/bash
# This script is configured to run with a k8s postStart lifecycle hook and must
# be very robust, a failure leads to failure for the user pod to start. This is
# also a script very hard to debug because its stdout output is discarded on
# success and only available on failures which we want to avoid at all cost.

# Sync the ~/curriculum folder from the cached git repo at /nh/curriculum. This
# way, we avoid reliance on GitHub and can manage a large amount of users at
# thte same time trying to access GitHub from a limited IP range that could be
# throttled. We fallback to using GitHub though.
gitpuller /nh/curriculum master ~/curriculum || gitpuller https://github.com/neurohackademy/nh2020-curriculum.git master ~/curriculum || true

# Provide a symbolic link to the /nh/data folder in the home directory.
[ -d ~/data ] || ln -s /nh/data/ ~/data || true

# Provide a symbolic link to the /nh/data/nilearn_data folder in the home
# directory. Requested by Elizabeth DuPre and Pierre Bellec.
[ -d ~/nilearn_data ] || ln -s /nh/data/nilearn_data ~/nilearn_data || true

# Provide a symbolic link to /nh/data/misc/.npythyrc. Requested by Noah Benson.
[ -f ~/.npythyrc ] || ln -s /nh/data/misc/.npythyrc ~/.npythyrc || true

# Remove empty lost+found directories
rmdir ~/lost+found/ || true
