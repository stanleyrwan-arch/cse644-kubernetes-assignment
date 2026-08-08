# Final Validation - CSE644 Assignment 02

## Actual local environment

- Host: macOS on arm64 Docker Desktop
- Kubernetes: Kind `cse644-k8s`, Kubernetes v1.36.1
- Kubernetes access: project-local `kubeconfig` only; it is excluded from Git and the package
- Image loading: `kind load docker-image` for `cse644-custom-nginx-k8s:v1` and `cse644-python-web-k8s:v1`

## Validated workloads and access

- `public-image-demo` runs `nginx:1.27-alpine`; logs and `kubectl exec` shell proof are captured.
- `custom-nginx` has two ready replicas and a `ClusterIP` Service.
- `python-web` runs `cse644-python-web-k8s:v1`, listens on container port 8888, and returns HTTP 200 from `/` and `/health`.
- `haproxy-edge` uses `custom-nginx.cse644.svc.cluster.local:80`, never an individual Pod address.
- ClusterIP DNS reached both application Services from the temporary in-cluster `discovery-client` Pod.
- NodePort: `localhost:30080` reaches HAProxy and returns the custom Nginx page.
- LoadBalancer Service: `python-web-loadbalancer` is type `LoadBalancer`; Kind's local mapped NodePort `localhost:30088` returned `/health` HTTP 200. Its `EXTERNAL-IP` remains pending because Kind has no cloud load-balancer controller.
- Ingress: `localhost:8082` with `Host: nginx.cse644.local` reached HAProxy and returned the custom Nginx page.
- PVC `python-web-data` remained Bound; `cse644-persistent-volume-proof` remained readable after the Python Pod was deleted and replaced.
- ConfigMap update changed the public `greeting` response to `Updated by Kubernetes ConfigMap without rebuilding` after rollout restart.
- Opaque Secret `app-runtime-secret` was observed only as type/key/length; the app reports `secret_configured: true` and never returns its value.
- Python readiness and liveness probes both use `/health`; the replacement Pod became `1/1 Ready`.

## Evidence inventory

- `01-deploy-cluster.txt` - cluster creation, image build/load, resources, controller startup
- `02-validation.txt` - workload operations, access tests, HAProxy, ConfigMap/Secret, probes, and PVC persistence

## Security statement

No passwords, tokens, API keys, private keys, kubeconfig files, Docker credentials, GitHub credentials, or Secret values are included. Kubernetes Secrets are not encrypted by default in the API server data store; production requires encryption at rest and least-privilege RBAC.
