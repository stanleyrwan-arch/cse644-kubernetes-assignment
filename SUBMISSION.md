# CSE644 Assignment 02 Submission

- Name: **ZIZE WAN**
- Local Kubernetes environment: **Kind v0.33.0-alpha on Docker Desktop, macOS/arm64**
- Cluster name: `cse644-k8s`
- Local image-loading method: `kind load docker-image --name cse644-k8s ...`
- GitHub repository: **To be created during final publication**

## Required demonstration checklist

- [x] Cluster is running and accessible through project-local kubeconfig
- [x] Public versioned image workload created, inspected, logged, and exec-tested
- [x] Custom Nginx Deployment has two ready replicas
- [x] Python application serves port 8888 and `/health`
- [x] Both applications reached through ClusterIP DNS
- [x] HAProxy reaches custom Nginx through Kubernetes service DNS
- [x] ClusterIP, NodePort, LoadBalancer resource, and Ingress manifests/access tests
- [x] PVC persists data after Python Pod replacement
- [x] ConfigMap visibly changes application behavior without rebuild
- [x] Opaque Secret is injected without exposing its value
- [x] Python readiness and liveness probes are configured and ready
- [x] Source, Dockerfiles, manifests, HAProxy config, scripts, and focused evidence included

## Evidence

- `evidence/terminal-output/01-deploy-cluster.txt`
- `evidence/terminal-output/02-validation.txt`
