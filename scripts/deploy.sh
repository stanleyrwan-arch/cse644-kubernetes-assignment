#!/usr/bin/env sh
set -eu

ASSIGNMENT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
KIND_BIN="$ASSIGNMENT_ROOT/tools/kind"
KUBECONFIG="$ASSIGNMENT_ROOT/kubeconfig"
export KUBECONFIG

"$KIND_BIN" create cluster --name cse644-k8s --config "$ASSIGNMENT_ROOT/kind-config.yaml" --kubeconfig "$KUBECONFIG"
kubectl label node cse644-k8s-control-plane ingress-ready=true --overwrite
docker build -t cse644-custom-nginx-k8s:v1 "$ASSIGNMENT_ROOT/apps/custom-nginx"
docker build -t cse644-python-web-k8s:v1 "$ASSIGNMENT_ROOT/apps/python-web"
"$KIND_BIN" load docker-image --name cse644-k8s cse644-custom-nginx-k8s:v1 cse644-python-web-k8s:v1

kubectl apply -f "$ASSIGNMENT_ROOT/manifests/00-namespace.yaml"
secret_value=$(openssl rand -hex 24)
kubectl -n cse644 create secret generic app-runtime-secret --from-literal=DEMO_SECRET="$secret_value"
unset secret_value
kubectl apply -f "$ASSIGNMENT_ROOT/manifests/01-public-image-demo.yaml"
kubectl apply -f "$ASSIGNMENT_ROOT/manifests/02-configmap.yaml"
kubectl apply -f "$ASSIGNMENT_ROOT/manifests/04-storage.yaml"
kubectl apply -f "$ASSIGNMENT_ROOT/manifests/05-applications.yaml"
kubectl apply -f "$ASSIGNMENT_ROOT/manifests/06-haproxy.yaml"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/kind/deploy.yaml
kubectl apply -f "$ASSIGNMENT_ROOT/manifests/08-ingress-controller-nodeport.yaml"
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=240s
kubectl apply -f "$ASSIGNMENT_ROOT/manifests/07-ingress.yaml"

kubectl -n cse644 rollout status deployment/public-image-demo --timeout=180s
kubectl -n cse644 rollout status deployment/custom-nginx --timeout=180s
kubectl -n cse644 rollout status deployment/python-web --timeout=180s
kubectl -n cse644 rollout status deployment/haproxy-edge --timeout=180s
