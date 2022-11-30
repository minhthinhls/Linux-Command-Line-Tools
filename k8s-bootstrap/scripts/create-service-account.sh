#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Create Kubernetes [Service Accounts] with [Cluster Role].
# @see {@link https://jenkins.io/doc/book/installing/kubernetes/}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Kubernetes v1.24.x [Service Accounts] generate without Base64 [Tokens].
# @see {@link https://kubernetes.io/docs/concepts/configuration/secret/#service-account-token-secrets}.
# @see {@link https://stackoverflow.com/questions/72256006/service-account-secret-is-not-listed-how-to-fix-it#72258300}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @usage > sh create-service-account.sh --name=jenkins-admin --namespace=jenkins-system ;
# ----------------------------------------------------------------------------------------------------------------------------------------------------

package="Create_Kubernetes_Service_Account" ;

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "$package - Create Kubernetes [Service Accounts] with [Cluster Role]."
      echo " "
      echo "$package [options] NULL [arguments]"
      echo " "
      echo "options:"
      echo "-h , --help                  show brief help"
      echo "-n , --name=NAME             specify kubernetes resource identifier"
      echo "-ns, --namespace=NAMESPACE   specify kubernetes registered namespace"
      exit 0
      ;;
    -ns|--namespace*)
      if test $# -gt 0; then
        if [[ $1 != *"="* ]]; then
          shift # If string contains "=" then do not shift arguments.
        fi
        NAMESPACE=$(echo $1 | sed -e 's/^[^=]*=//g');
      else
        echo "No namespace specified";
        exit 1;
      fi
      shift
      ;;
    -n|--name*)
      if test $# -gt 0; then
        if [[ $1 != *"="* ]]; then
          shift # If string contains "=" then do not shift arguments.
        fi
        NAME=$(echo $1 | sed -e 's/^[^=]*=//g');
      else
        echo "No name specified";
        exit 1;
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

cat << EOF | kubectl apply --filename -
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: ${NAME}
rules:
  - apiGroups:
      - '' # An empty string designates the core API group [$${apiVersion} == "v1"].
    resources:
      - pods
      - nodes
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - apps
      - extensions
    resources:
      - pods
      - replicasets
      - deployments
    verbs:
      - get
      - list
      - patch # Rollout Restart Permission.
      - update
      - watch

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${NAME}
  namespace: ${NAMESPACE}

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${NAME}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: ${NAME}
subjects:
  - kind: ServiceAccount
    name: ${NAME}
    namespace: ${NAMESPACE}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @description: Generate Base64 [Secret Tokens] for [Service Accounts] within Kubernetes (v1.24+).
# ----------------------------------------------------------------------------------------------------------------------------------------------------
---
apiVersion: v1
kind: Secret
metadata:
  name: ${NAME}-token
  namespace: ${NAMESPACE}
  annotations:
    kubernetes.io/service-account.name: ${NAME}
type: kubernetes.io/service-account-token
data:
  # You can include additional key value pairs as you do with Opaque Secrets.
  extra: YmFyCg==

EOF
