#!/bin/bash

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# @see {@link https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash#7069755}
# @usage: delete-certs.sh --tls-name=wildcard-root-tls argocd-system jenkins-system monitoring;
# ----------------------------------------------------------------------------------------------------------------------------------------------------

package="Delete_Kubernetes_Certificate"

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "$package - Push all Certificate into Kubernetes System."
      echo " "
      echo "$package [options] namespaces [arguments]"
      echo " "
      echo "options:"
      echo "-h, --help                  show brief help"
      echo "-n, --tls-name=SECRET_NAME  specify certificate as kubernetes tls-secret"
      exit 0
      ;;
    -n|--tls-name*)
      if test $# -gt 0; then
        if [[ $1 != *"="* ]]; then
          shift # If string contains "=" then do not shift arguments.
        fi
        SECRET_NAME=$(echo $1 | sed -e 's/^[^=]*=//g');
      else
        echo "No tls secret name specified";
        exit 1;
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

# @see {@link https://stackoverflow.com/questions/9057387/process-all-arguments-except-the-first-one-in-a-bash-script}
for namespace in "${@:1}"; do
  kubectl delete secret "$SECRET_NAME" \
  --namespace="$namespace"             ;
done;
