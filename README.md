# CSE644 Assignment 02 - Local Kubernetes Application Platform

Student: **ZIZE WAN**
Local Kubernetes environment: **Kind on Docker Desktop (macOS/arm64)**

This project deploys a replicated custom Nginx application, a Python Flask application on port 8888, and HAProxy as a Kubernetes edge component. It uses versioned image tags only.

## Architecture

```text
Ingress (localhost:8082, Host: nginx.cse644.local)
  -> haproxy-edge Service -> HAProxy Deployment
  -> custom-nginx Service -> 2 custom-nginx Pods

NodePort (localhost:30080) -> haproxy-nodeport -> HAProxy -> custom-nginx
LoadBalancer Service (NodePort local access localhost:30088) -> python-web Pod :8888
ClusterIP Services -> internal DNS access from an in-cluster client
python-web Pod -> PersistentVolumeClaim python-web-data
```

## Prerequisites

- Docker Desktop running
- `kubectl`
- `curl`, `openssl`, and a POSIX shell

The bootstrap script downloads Kind to `tools/kind`; the deployment script writes a project-local `kubeconfig`. Both are excluded from source control. The workflow never changes the default user kubeconfig.

## Build, load, and deploy

```sh
chmod +x scripts/bootstrap-kind.sh scripts/deploy.sh scripts/cleanup.sh
./scripts/bootstrap-kind.sh
./scripts/deploy.sh
```

The local-image loading approach is Kind's supported image-loading command:

```sh
tools/kind load docker-image --name cse644-k8s \
  cse644-custom-nginx-k8s:v1 cse644-python-web-k8s:v1
```

The application manifests use those versioned local tags with `imagePullPolicy: IfNotPresent`.

The actual Opaque Secret is created at deploy time from a generated value and is not saved, printed, committed, or returned by the application. `manifests/03-secret.example.yaml` is a non-secret template only.

## Validation commands

```sh
export KUBECONFIG="$PWD/kubeconfig"
kubectl get nodes
kubectl -n cse644 get deploy,pods,svc,pvc

# Public image workload, logs, and non-interactive proof of shell execution
kubectl -n cse644 logs deploy/public-image-demo
kubectl -n cse644 exec deploy/public-image-demo -- sh -c 'echo interactive-shell-success'
# True interactive command: kubectl -n cse644 exec -it deploy/public-image-demo -- sh

# ClusterIP and service discovery
kubectl -n cse644 run discovery-client --rm -i --restart=Never \
  --image=curlimages/curl:8.10.1 -- curl -s http://custom-nginx.cse644.svc.cluster.local/

# NodePort and HAProxy proxy proof
curl -i http://localhost:30080

# LoadBalancer resource local access through its explicit NodePort
curl -i http://localhost:30088/health

# Ingress through HAProxy (the Kind mapping is host 8082 -> NodePort 30082)
curl -i -H 'Host: nginx.cse644.local' http://localhost:8082/

# ConfigMap behavior and health
kubectl -n cse644 port-forward svc/python-web 8888:8888
curl -i http://localhost:8888/
curl -i http://localhost:8888/health

# Persistent storage: write, replace the pod, then read
curl -i -X POST http://localhost:8888/data -H 'Content-Type: application/json' \
  -d '{"message":"cse644-persistent-volume-proof"}'
kubectl -n cse644 delete pod -l app=python-web
kubectl -n cse644 rollout status deployment/python-web
curl -i http://localhost:8888/data
```

Kind has no cloud load-balancer controller. The `python-web-loadbalancer` resource is still a Kubernetes `LoadBalancer` Service; the assignment uses its explicitly assigned NodePort `30088`, mapped by the Kind node to `localhost:30088`, as the appropriate local access method. The manifest and `kubectl get svc` output identify the Service type.

## Configuration, Secret, and probes

`python-web-config` ConfigMap supplies the visible `GREETING` and `ENVIRONMENT` response fields without rebuilding the image. The app reports only `secret_configured: true/false`; it never displays `DEMO_SECRET`.

The Python readiness and liveness probes call `/health`. Readiness determines whether the Service sends requests to the Pod; liveness tells Kubernetes when to restart an unhealthy container.

Kubernetes Secrets are not encrypted by default in the API server's underlying data store. A production cluster requires encryption at rest and least-privilege access controls, including restrictive RBAC.

## Cleanup

```sh
./scripts/cleanup.sh
```

## Security statement

No passwords, Docker Hub tokens, GitHub tokens, kubeconfig files, private keys, API keys, credentials, or Secret values are committed.
