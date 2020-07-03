# Getting access

Who can successfully login to their GitHub account to the JupyterHub is
controlled by an _Access Control List_ (ACL).

- Admins become JupyterHub administrators
- Instructors get read/write access to the shared `/nh/data` storage
- Participants get read to the shared `/nh/data` storage

As an instructor, please add yourself to the
[ACL](https://github.com/neurohackademy/nh2020-jupyterhub/edit/master/deployments/hub-neurohackademy-org/config/common.yaml).
You do this by forking the GitHub repository and proposing a change to the file
where you have added your GitHub username. Just write "acl: adding myself" in
the title of the suggested change (commit message).
