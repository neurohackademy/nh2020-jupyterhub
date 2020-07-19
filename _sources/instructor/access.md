# Getting access

Who successfully can login to their GitHub account to the JupyterHub is
determined by an _Access Control List_ (ACL). While all users listed in the ACL
will be able to login, admins become JupyterHub administrators and instructors
get write permissions to shared storage in `/nh/data` or `~/data` which is is a
symlink to `/nh/data`.

As an instructor, please add yourself to the
[ACL](https://github.com/neurohackademy/nh2020-jupyterhub/edit/master/deployments/hub-neurohackademy-org/config/common.yaml).

```{note}
You add yourself by following the link above. Fork the GitHub repository and
propose a change to the file where you add your GitHub username to the list.
Just write "acl: adding myself" in the title of the suggested change (commit
message).
```
