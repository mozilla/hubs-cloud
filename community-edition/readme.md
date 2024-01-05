# Introduction

Community Edition is a free tool designed to help developers deploy the full Hubs stack on cloud computing software of their choosing. Community Edition simplifies and automates most of the complex deployment process using Kubernetes, a containerized software orchestration system.

Community Edition is designed for developers capable of working with the full Hubs stack and of navigating complex application infrastructure. With Community Edition, developers are responsible for designing, building, hosting, and maintaining their software throughout its lifetime. In order to create a production-ready version of Hubs similar to Hubs Cloud, Developers using Community Edition will need to implement additional features and customizations outside of those listed in this repo. See "Considerations for Production Environment".

# Why Kubernetes

Kubernetes is an industry standard for allowing developers to build, deploy, and scale s efficiently and reliably. Benefits to Kubernetes include:

- [Portability, Extensibility, and Open Source](https://kubernetes.io/docs/concepts/overview/)
- [Availability in many cloud environments](https://kubernetes.io/docs/setup/production-environment/turnkey-solutions/)
- Many options for single server deployments (ie. minikube, k3s, microk8s, kind)

# Prerequisites

Before deploying the charts in this repo, you will need to choose and configure the following services...

- A hosting service with a Kubernetes cluster to receive your Community Edition deployment spec
- Kubernetes controls on your device
- A DNS service to reach Hubs on a domain
- Port to expose services to client
  - TCP: 80, 443, 4443, 5349
  - UDP: 35000 -> 60000
- An SMTP service for login emails and accounts (for login emails, ie. [use gmail as smtp](https://support.google.com/a/answer/176600?hl=en))

# Optional Docker Builder

To build the hcce.yaml file inside a docker container run the following:

> Add your chosen services into `render_hcce.sh` with a text editor first

```
docker build . -t hubs-ce-builder:latest
docker run --rm -it -v <COMMUNITY_EDITION_PATH>:/app hubs-ce-builder:latest
# Then to deploy to k8
kubectl apply -f ./hcce.yaml
```

once the container has run, you should see a new file (hcce.yaml) in your COMMUNITY_EDITION_PATH

To build the cbb.yaml file inside a docker container run the following:

> Add your chosen services into `render_cbb.sh` with a text editor first

```
docker build . -t hubs-ce-builder-cbb:latest
docker run --rm -it -v <COMMUNITY_EDITION_PATH>:/app hubs-ce-builder-cbb:latest
```

once the container has run, you should see a new file (cbb.yaml) in your COMMUNITY_EDITION_PATH

# Deploy to Kubernetes

To deploy to your K8s cluster on your chosen hosting solution, follow these steps:

- Add your chosen services into `render_hcce.sh` with a text editor
- Run `bash render_hcce.sh && kubectl apply -f hcce.yaml`
- Expose the services

  - Run `kubectl -n <hcce_namespace> get svc lb` to find it's external ip
  - On your DNS service, create four A-records to route your domains to the external ip of your K8s cluster
    - <root_domain>
    - assets.<root_domain>
    - stream.<root_domain>
    - cors.<root_domain>

- Configure your HTTPS certs
  - Option #1: bring your own
    - package the certs into kubernetes secrets named `cert-<domain>` under the deploy namespace
  - Option #2: use Hubs' certbotbot
    - edit configs into `cbb.sh` with a text editor
    - `bash cbb.sh`

# Example -- A "hello-world" instance with vm on gcp

#### Step 1: Make a kubernetes environment

Replace `hcce-vm-1` and `us-central1-a` with your desired name and zone. Check [the official doc](https://cloud.google.com/sdk/gcloud/reference/compute/instances/create) for more options.

````

### login gcp

gcloud auth login

### create a vm

`gcloud compute instances create hcce-vm-1 --zone=us-central1-a`

### ssh to the vm

`gcloud compute ssh --project=hubs-dev-333333 --zone=us-central1-a geng-test-2`

### prepare the vm

`sudo apt update && sudo apt install npm && sudo npm install pem-jwk -g`

### install k3s without traefik -- read https://docs.k3s.io/ for more info

- `curl https://get.k3s.io/ | INSTALL_K3S_EXEC="--disable=traefik" sh -`

```

#### Step 2: Deploy to kubernetes
- Add your services to `render_hcce.sh`
- Run `bash render_hcce.sh && sudo k3s kubectl apply -f hcce.yaml`

#### Step 3: connect the ingress
- find the vm's external ip
- create a-records to the dns
- makesure the required ports are exposed to the client

# example -- a "hello-world" instance with managed kubernetes on gcp
#### Step 1: make a kubernetes environment
replace `hcce-gke-1` and `us-central1-a` with your desired name and zone, check [official doc](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create) for more options
```

# login gcp

gcloud auth login

# create gke cluster

gcloud container clusters create hcce-gke-1 --zone=us-central1-a

# get creds for kubectl

gcloud container clusters get-credentials --region us-central1-a hcce-gke-1

```

#### Step 2: deploy to kubernetes
`bash render_hcce.sh && sudo k3s kubectl apply -f hcce.yaml`

#### Step 3: connect the ingress
- find the external ip with `kubectl -n hcce get svc lb`
- dns and firewall steps are the same <link to above>


# example -- a "potentially-somewhat-production-ready" instance on aws
- comming soon

# considerations for production environment
- infra
    - easy -- use a managed kubernetes
    - hard -- https://kubernetes.io/docs/setup/production-environment/
- security
    - password and keys overview
    - add a waf
- scalability
    - stateful services
        - pgsql
            - use a managed pgsql ie. rds on aws or cloudsql on gcp
            - roll your own
                - <links to some guides to run pgsql in k8s>
        - reticulum
            - use a network/shared storage for reticulum's /storage mount
    - stateless services (all except reticulum and pgsql)
        - just run multiple replicas
        - use hpa
- devops
    - the yaml file is the entire infra on kubernetes, use a git to track changes and an ops pipeline to auto deploy
        - ie put the yaml file on a github repo and use github action to deploy to your hosting env
    - use dev env for staging/testing
        - use spot instances for nodes to save $
        - develop and integrate automated testing scripts into the ops pipeline
- Infrastructure
  - Easy -- use managed kubernetes
  - Hard -- make it [production-ready](https://kubernetes.io/docs/setup/production-environment/)
- Security
  - Password and Keys
  - Add a WAF
- Scalability
  - Stateful services
    - PostgreSQL
      - use a managed pgsql ie. rds on aws or cloudsql on gcp
      - roll your own
    - Reticulum
      - use a network/shared storage for reticulum's /storage mount
  - Stateless Services (all except reticulum and pgsql)
    - Run multiple replicas
    - Use HPS
- Devops
  - The two yaml files in this repo are the entire infra on kubernetes. You may want to use git to track changes and an ops pipeline to auto deploy.
    - ex. Put the yaml file on a github repo and use github action to deploy to your hosting env.
  - Use dev env for staging/testing.
    - Use spot instances for nodes to save money.
    - Develop and integrate automated testing scripts into the ops pipeline
  - Configure devops for deploying custom versions of Spoke, Hubs, and Reticulum
```
