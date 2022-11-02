#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://stackoverflow.com/questions/47770676/how-to-create-a-kubectl-config-file-for-serviceaccount#47776588}.
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @usage > sh create-kube-config.sh --name=jenkins-admin --namespace=jenkins-system --path=$HOME/.kube/service_account.conf ;
# ----------------------------------------------------------------------------------------------------------------------------------------------------

package="Create_Service_Account_Kube_Config" ;

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "$package - Create Kubernetes [Service Accounts] with [Cluster Role]."
      echo " "
      echo "$package [options] NULL [arguments]"
      echo " "
      echo "options:"
      echo "-h , --help                  show brief help"
      echo "-p , --path=PATH             specify output path for kube.config"
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
    -p|--path*)
      if test $# -gt 0; then
        if [[ $1 != *"="* ]]; then
          shift # If string contains "=" then do not shift arguments.
        fi
        FILE=$(echo $1 | sed -e 's/^[^=]*=//g');
      else
        echo "No output path specified";
        exit 1;
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

# @description: Kubernetes API Server Endpoints.
export API_SERVER=https://control-plane.e8s.io:6443

CAD=$(kubectl get secret/"$NAME-token" --namespace="$NAMESPACE" -o jsonpath='{.data.ca\.crt}');
TOKEN=$(kubectl get secret/"$NAME-token" --namespace="$NAMESPACE" -o jsonpath='{.data.token}' | base64 --decode);

# @description: Must create file before writing contents.
touch "$FILE" ;

cat << EOF | sudo tee "$FILE" ;
---
apiVersion: v1
kind: Config
preferences: { }
current-context: gcp-k8s-admin@google-cloud.e8s.io

contexts:
  - name: gcp-k8s-admin@google-cloud.e8s.io
    context:
      namespace: kube-system
      cluster: google-cloud.e8s.io
      user: gcp-k8s-admin

clusters:
  - name: google-cloud.e8s.io
    cluster:
      certificate-authority-data: ${CAD}
      server: ${API_SERVER}

users:
  - name: gcp-k8s-admin
    user:
      token: ${TOKEN}

EOF
