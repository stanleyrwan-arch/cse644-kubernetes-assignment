#!/usr/bin/env sh
set -eu

ASSIGNMENT_ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
KUBECONFIG="$ASSIGNMENT_ROOT/kubeconfig"
export KUBECONFIG
"$ASSIGNMENT_ROOT/tools/kind" delete cluster --name cse644-k8s
