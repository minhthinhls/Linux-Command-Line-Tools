#!/bin/bash

# shellcheck disable=SC2164

# @description - Delete Redis Cluster Deployment.
kubectl delete StatefulSet redis ;
kubectl delete Job redis-bootstrap ;
kubectl delete pod redis-0 redis-1 redis-2 redis-3 redis-4 redis-5 redis-6 redis-7 redis-8 ;

redis-cli -c \
-h redis-0.headless.redis-cluster-product.svc.cluster.local \
--pass ReRuiEZDyXvEtc8NvgqESeKgbiFSJWADUX0sJlFs42V6CZ807M   \
cluster nodes ;

watch redis-cli -c \
-h redis-0.headless.redis-cluster-product.svc.cluster.local \
--pass ReRuiEZDyXvEtc8NvgqESeKgbiFSJWADUX0sJlFs42V6CZ807M   \
cluster nodes ;

dig +short headless.redis-cluster-product.svc.cluster.local \
| awk '{print "CLUSTER MEET "$1" 6379"}' ;

# @description - Apply Bundled HELM Chart with Output Redirection.
helm template --values ./values.yaml redis-cluster . | kubectl apply --filename - ;

# @description: [Render & Display] Specific Templates.
sh <<EOF
cd /root/Linux-Command-Line-Tools/k8s-bootstrap/resources/kubernetes/redis-cluster ;
helm template redis-cluster product --show-only templates/bootstrap-job.yaml ; # helm-redis-bootstrap-job-product
EOF

# @description: [Compile & Deploy] Specific Templates.
sh <<EOF
cd /root/Linux-Command-Line-Tools/k8s-bootstrap/resources/kubernetes/redis-cluster ;
helm template redis-cluster product --show-only templates/bootstrap-job.yaml | kubectl apply --filename - ; # helm-redis-bootstrap-job-product
EOF

# @description: [Compile & Deploy] Chart Templates.
sh <<EOF
cd /root/Linux-Command-Line-Tools/k8s-bootstrap/resources/kubernetes/redis-cluster ;
helm template redis-cluster product | kubectl apply --filename - ; # helm-redis-cluster-product
EOF
