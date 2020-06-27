# Work log

This is a work log made by Erik Sundell. It is meant to provide insights into
the steps I take along the way to reach the desired outcome.

## Statement of work

1. Design for a scalable and configurable Jupyterhub for instruction of
   NeuroHackademy. The hub has the following desiderata:

    1. Scale to thousands of users on a Kubernetes cluster.
    1. Gate usage with GitHub authentication.
    1. Auto-deploy single docker image for the course with hubploy/GitHub
       actions.

2. Implement the solution within a Google Cloud Platform (GCP) project owned and
   billed by an existing eScience Google Cloud Platform account.

3. Maintain the solution and keep it running for the duration of the course.

4. To provide public documentation to help anyone create a similar bootcamp
   setup in the future, involving technical procedures as well as guidance on
   architectural decisions, at 2i2c/zero-to bootcamp. 

## A place for documentation

I created a Jupyter Book which you currently read using the
[jupyter-book](https://github.com/executablebooks/jupyter-book) CLI in order to
be able to document my work from the start.

## Architecture plans

While working towards a solution, I'll rubber duck some discussion along the
way.

### Git repos

A single repo to manage: Kubernetes deployment, documentation for
administrators/instructors/students, and the Jupyter user environment.

### A single user environment

For a course with many lectures, we may have conflicting environment
constraints. Due to this, it could make sense to allow lecturers build their own
environment. Me and Ariel have opted to not go that route, considerations behind
this decision included:

1. A single course will likely not need too much customization of the user
   environment between lectures, so its likely we can avoid conflicting
   dependencies in a single Docker image.

1. Its practically easier to test a single environment to work as intended
   than many.

1. When a user arrives, it should preferably not need to wait for a new server
   (Kubernetes node) to startup, and neither wait for the Docker image it needs
   to be downloaded to that server. With a single or very few docker images, it
   is far easier to ensure the user doesn't need to wait for a downloaded image
   than with for example ten different.

   When a new Kubernetes node is added the JupyterHub Helm chart allows for
   images to be pre-pulled or downloaded ahead of time before users arrive. If
   there is only one image to pull, the node will be ready far quicker than if
   we need to pull ten images. This can be a difference of two to twenty
   minutes.

### nginx-ingress and cert-manager

HTTPS is a must, but how we set it up can be chosen? We can either use the a TLS
termination proxy that also can speak with Let's Encrypt to acquire a
certificate as part of the JupyterHub Helm chart, referred to as `autohttps`.
Another option is to use a combination of
[nginx-ingress](https://hub.helm.sh/charts/stable/nginx-ingress) and
[cert-manager](https://hub.helm.sh/charts/jetstack/cert-manager).

I think either option could work well to provide TLS termination for JupyterHub
specifically. But, only nginx-ingress + cert-manager can provide certificates
and TLS termination for JupyterHub and other services at the same Grafana. It is
also well tested and have mechanisms to scale in a highly available way. Due to
this, I'm choosing to use nginx-ingress and cert-manager over autohttps.

### Lecture datasets

A goal is to enable instructors to provide datasets to students for their
lectures. It is good if it is easy for both the instructors to do this, and the
students to access it. A storage area that is read/write for instructors and
read only for students fits this. But, how scalable would such solution be?

Google's managed Filestore [recommends to not have more than 500
clients](https://cloud.google.com/filestore/docs/limits). We want to scale to
some thousands of students, but perhaps we don't need to have some thousands of
NSF clients! If instead of making each student a client of the NSF server, we
make each Kubernetes node a client, and fit 4-8 users of each node, it becomes
far more sustainable.

I'm thinking that we could either let Kubernetes nodes copy the NSF data on
startup from the NSF server and expose it using a [hostPath
volume](https://kubernetes.io/docs/concepts/storage/volumes/#hostpath) to the
user Pods, or expose it directly using a hostPath volume. Copying data on
startup will improve performance, but not allow for updates if the data changes.

We could also write data to object storage and grab it from there or similar,
but I think for now, a reliable idea is to let the new nodes mount NSF data and
copy it to a local path which is exposed to users using a hostPath.

### A meta Helm chart mostly depending on other charts

It can often make life easier to have a single Helm chart that depends on other
helm charts so one can add some kubernetes resources if needed and configure it
with values as well.

### GCP

I've tried to pin down exactly what to install. The input I have regarding
resources are verbal, and from my memory I recall the need for about 12GB memory
per user. Due to the heavy memory need per user, I deem that it may make sense
to use ultramem nodes with 961GB memory / 40 CPU cores with a 24GB / 1 CPU
allowing for each user to have at least 0.5 CPU and 12GB memory but potentially
use far more CPU if other users isn't running work.

- 1 VPC network (new) to avoid the mess in the default VPC network (free)
- 1 Cloud NAT (free, allows us to keep track of the IP of outbound traffic if we
  need to whitelist them)
- 1 SQL instance, n1-standard-2
- 1 NFS server, 1 TB Filestore
- 1 Kubernetes cluster, private, k8s version 1.16.9, us-central1
   - Regional cluster for HA k8s api-server, but nodes only in us-central1-c
   - 1 n1-standard-8 for JupyterHub etc.
   - 1 n1-highmem-8 for users, w. 52GB for four 12GB users at all time
   - 0-X m1-ultramem-40 w. 961GB for eighty 12GB users / node for 80 users /
     node and 1600 simultaneous users for 20 nodes


### GitOps and staging/production splits

I think the main reason to split a single deployment into staging/production is
to test something in staging before upgrades in production because it is too
sensitive. But, what kinds of upgrades do we want to test in staging? I reason
that we only want to test updates of images we build for the user environment.

The statement of work specifies hubploy / GitHub actions and hubploy may imply a
staging environment though. I think hubploy implies the need for a staging
environment though, so I'll need to investigate it a bit. If a staging
environment is configured, I need to decide how much is made common between
production and staging. Do we use separate k8s clusters, separate namespaces,
separate grafana/prometheus, etc.

### git secret management

git-crypt and a symmetric key seems sensible to me for this short lived
deployment, while it may make sense to use SOPS for a long lived solution with
GitOps to do everything.

### hubploy learning

I've not used hubploy before and had to learn some parts. I found
[yuvipanda/hubploy-template](https://github.com/yuvipanda/hubploy-template) and
a PR to [yuvipanda/hubploy](https://github.com/yuvipanda/hubploy/pull/78) to be
very relevant and two minor
([1](https://github.com/yuvipanda/hubploy-template/pull/6),
[2](https://github.com/yuvipanda/hubploy/pull/80)) documentation PRs.

Some conclusions:
- can be used with Helm 3
- build docker images using repo2docker configurations
- accept GCP credentials and push images to google's container registry
- accept GCP credentials to work against a GKE cluster while making `helm upgrade` with image referenced updated.
- hubploy does not integrated with git-crypt or sops, but sops seems like the way to go:
   - https://github.com/berkeley-dsep-infra/datahub/issues/596
   - https://github.com/2i2c-org/jupyterhub-deploy

### GCP Networking

I opted to setup a dedicated VPC network, so everything in it can be assumed to
have a meaning of relevance, as compared to adding more parts to the default VPC
network. Hopefully that will make it easier to understand the setup in the
future.

Here is the plan for IP ranges, note that the external reservations are IP
addresses that are intentionally kept free to ensure that we can use VPC network
peering to another VPC network that will map to that ranges. This is relevant
because the Kubernetes API-servers in a GKE cluster will reside in another GCP
project not managed by us, and then VPC network peered into this project. The
same goes for many other managed services like Filestore and Cloud SQL.

__VPC Network: `neurohackademy`__
Type                   | name      | CIDR          | Required /x
---------------------- | --------- | ------------- | -----------
*Subnet k8s*           |           |               |
(external reservation) | master    | 10.60.0.0/28  | /28
(external reservation) | filestore | 10.60.0.16/29 | /29
(external reservation) | sql       | 10.60.16.0/20 | /20
primary IP range       | nodes     | 10.60.32.0/20 | /20
secondary IP range     | services  | 10.60.48.0/20 | /20
secondary IP range     | pods      | 10.64.0.0/14  | /14

### GCP IAM

I think it is a good practice to create service accounts for various needs, so
I'm creating one for:

- Hubploy's access to the projects container registry
- Hubploy's access to the projects GKE cluster
- The nodes of the GKE cluster
- The Cloud SQL instance
- The Filestore instance

### GCP Quotas

I looked through all the quotas, and given the plan to use m1-ultramem-40 nodes
with ~80 user each on them, I concluded we would fit 2400 users in 30 nodes.
30*40 is 1200 CPUs and our current CPU quota is 500. So, due to that, it felt
sensible to request an increase. I requested a quota of 1500 CPUs.

### GKE

I created a GKE cluster, and this was the gcloud equivalent command. It failed 

```
gcloud beta container --project "neurohackademy" clusters create "nh-2020" --region "us-east1" --no-enable-basic-auth --cluster-version "1.16.9-gke.6" --machine-type "n1-standard-4" --image-type "COS" --disk-type "pd-standard" --disk-size "100" --node-labels hub.jupyter.org/node-purpose=core --metadata disable-legacy-endpoints=true --service-account "gke-node-core@neurohackademy.iam.gserviceaccount.com" --num-nodes "1" --enable-stackdriver-kubernetes --enable-private-nodes --master-ipv4-cidr "10.60.0.0/28" --enable-ip-alias --network "projects/neurohackademy/global/networks/neurohackademy" --subnetwork "projects/neurohackademy/regions/us-east1/subnetworks/us-east1" --cluster-secondary-range-name "pods" --services-secondary-range-name "services" --default-max-pods-per-node "110" --enable-network-policy --enable-master-authorized-networks --master-authorized-networks 0.0.0.0/0 --addons HorizontalPodAutoscaling,HttpLoadBalancing --no-enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --node-locations "us-east1-b" && gcloud beta container --project "neurohackademy" node-pools create "user" --cluster "nh-2020" --region "us-east1" --node-version "1.16.9-gke.6" --machine-type "m1-ultramem-40" --image-type "COS" --disk-type "pd-standard" --disk-size "100" --node-labels hub.jupyter.org/node-purpose=user --metadata disable-legacy-endpoints=true --node-taints hub.jupyter.org_dedicated=user:NoSchedule --service-account "gke-node-user@neurohackademy.iam.gserviceaccount.com" --num-nodes "0" --enable-autoscaling --min-nodes "0" --max-nodes "25" --no-enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --node-locations "us-east1-b"
```

Apparently only two m1-ultramem-40 nodes were available, which was unexpected. I
received the following error.

> Google Compute Engine: Not all instances running in IGM after 56.02936237s. Expect 3. Current errors: [GCE_STOCKOUT]: Instance 'gke-nha-2020-user-8565ecfe-phhk' creation failed: The zone 'projects/neurohackademy/zones/us-east1-c' does not have enough resources available to fulfill the request. '(resource type:compute)'.

I learned that there was no easy way to inspect the availability, but
successfully scaled to 25 nodes on us-central1-a for ~5 minutes brief moment and
decided to go with that over us-central1-c. I concluded that it cost me about 13
USD to make that test.

---

I got a response from Google support, they recommended to use us-east1. In the
[GCP docs about zones and their
resources](https://cloud.google.com/compute/docs/regions-zones#available) I
concluded that us-east1-(b,c,d) were allowed zones, but only b and d had
m1-ultramem-40 nodes. I tried starting up 25 nodes on us-east1-d first but I got
stuck at 2 and got the GCP_STOCKOUT issue on the rest.

On us-east1-b I managed to startup 25 nodes though, so now I'm going to assume
the preparation is as good as it get.

### SOPS

Seeing that Yuvi Panda advocated for a transition to SOPS and put in work to
make hubploy use it among other things, it made sense to set that up instead of
staying with git-crypt. See for example [this open
PR](https://github.com/yuvipanda/hubploy/pull/81).

I used [these steps part of SOPS
documentation](https://github.com/mozilla/sops#encrypting-using-gcp-kms) to
setup a Google Cloud KMS keyring. Here is [a link to the GCP web
console](https://console.cloud.google.com/security/kms?project=neurohackademy).

```shell
# create a keyring
gcloud kms keyrings create nh-2020 --location global
gcloud kms keyrings list --location global
# resulting keyring: projects/neurohackademy/locations/global/keyRings/nh-2020

# create a key
gcloud kms keys create main --location global --keyring nh-2020 --purpose encryption
gcloud kms keys list --location global --keyring nh-2020
# resulting key: projects/neurohackademy/locations/global/keyRings/nh-2020/cryptoKeys/main
```

```yaml
# content of .sops.yaml
creation_rules:
  - path_regex: .*/secrets/.*
    gcp_kms: projects/neurohackademy/locations/global/keyRings/nh-2020/cryptoKeys/main
```

```shell
# login to a google cloud account
gcloud auth login

 # request a credentials file for use
gcloud auth application-default login

# encrypt a new file
sops --encrypt --in-place deployments/hub.neurohackademy.org/secrets/prod.yaml

# edit the file in memory
sops deployments/hub.neurohackademy.org/secrets/prod.yaml
```

### Hubploy

I created two GCP service accounts, hubploy-gcr and hubploy-gke. I then created
and downloaded .json keys to act as them and stored them in
deployments/hub.neurohackademy.org/secrets as gcr-key.json and gke-key.json.

In the [IAM
panel](https://console.cloud.google.com/iam-admin/iam?project=neurohackademy)
that couples accounts with permissions, I gave the hubploy-gcr account _Storage
Admin_ rights to both be able to read and push. I also gave the hubploy-gke
account right to be a _Kubernetes Engine Cluster Admin_. Initially I tried with
Storage Object Admin, but then I lacked the `storage.buckets.create` permission
which is used if a new image name is to be used, due to this, _Storage Admin_ is
needed.

This allowed the development of hubploy in
https://github.com/yuvipanda/hubploy/pull/81 which we hopefully will get merged
soon to work good enough to build images like this.

```shell
hubploy build hub.neurohackademy.org --check-registry
```

### Registry access

When a node has a image that it needs, kubelet running on the node will try
download it. This can fail for various reasons and I ran into two of them.

##### Issue 1 - no public IP to egress from

The private GKE clusters nodes had no public IP, so traffic could not leave
internet because it then has no return address. This was quickly solved by
setting up a Cloud NAT on GCP, this is extremely painless.

##### Issue 2 - access to container registry

I made access to the registry public to ensure both GKE can reach it without
needing to configure imagePullSecrets which is very doable, but to also ensure
others can pull this from their own computers etc.

ref: https://console.cloud.google.com/gcr/settings?project=neurohackademy

I wonder if it is possible to give public access to individual images. The GCP
container registry is working tightly against their Cloud Storage where the
images actually reside. Each image will get their own bucket, and you can give
permissions specific to buckets, but is that enough to make the image's bucket
public or will the container registry refuse to list it no matter what because
access to the container registry itself is not public?
